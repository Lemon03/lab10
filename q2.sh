#!/bin/bash

CONTENT_LENGTH=$(printf '%d' "$CONTENT_LENGTH")

POST_DATA=""
if [ "$CONTENT_LENGTH" -gt 0 ]; then
    POST_DATA=$(cat)
fi

BOUNDARY=$(echo $CONTENT_TYPE | sed 's/.*boundary=\(.*\)/\1/')

username=""
password=""

# Process POST data to extract username and password
while IFS= read -r line; do
    if [[ "$line" == *'name="username"'* ]]; then
        IFS= read -r line
        username=$(echo "$line" | tr -d '\r')
    elif [[ "$line" == *'name="password"'* ]]; then
        IFS= read -r line
        password=$(echo "$line" | tr -d '\r')
    fi
done <<< "$(echo "$POST_DATA" | tr '\n' '\r' | sed -n -e "s/--$BOUNDARY/\n/gp" | tr '\r' '\n')"

if [ "$username" == "langara" ] && [ "$password" == "hello" ]; then
    HEADER='{"alg":"HS256","typ":"JWT"}'
    PAYLOAD="{\"username\":\"$username\",\"exp\":\"$(( $(date +%s) + 3600 ))\"}"

    # Encode Header and Payload
    B64_HEADER=$(echo -n "$HEADER" | base64 | tr '+' '-' | tr '/' '_' | tr -d '=')
    B64_PAYLOAD=$(echo -n "$PAYLOAD" | base64 | tr '+' '-' | tr '/' '_' | tr -d '=')

    # Signature
    SIGNATURE=$(echo -n "${B64_HEADER}.${B64_PAYLOAD}" \
        | openssl dgst -sha256 -hmac "your_secret_key" -binary \
        | base64 | tr '+' '-' | tr '/' '_' | tr -d '=')

    # Complete JWT
    JWT="${B64_HEADER}.${B64_PAYLOAD}.${SIGNATURE}"

    echo "Content-type: text/plain"
    echo "Set-Cookie: JWT=$JWT; Path=/; HttpOnly"
    echo ""
    echo "Status: 200 OK"
    echo "Login successful."
else
    echo "Content-type: text/plain"
    echo ""
    echo "Status: 401 Unauthorized"
    echo "Invalid credentials."
    echo "Debug: Starting script" >&2
fi




