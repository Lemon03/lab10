#!/bin/bash

POST_DATA=$(cat)

decoded_data=$(echo "$POST_DATA" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')
username=$(echo "$decoded_data" | grep -oE 'username=[^&]+' | cut -d '=' -f2)
password=$(echo "$decoded_data" | grep -oE 'password=[^&]+' | cut -d '=' -f2)

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




