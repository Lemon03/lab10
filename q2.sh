#!/bin/bash

read POST_DATA

decoded_data=$(echo "$POST_DATA" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')

username=$(echo "$decoded_data" | grep -oE 'username=[^&]+' | cut -d '=' -f2)
password=$(echo "$decoded_data" | grep -oE 'password=[^&]+' | cut -d '=' -f2)

header="Content-type: text/plain"
body=""

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

    header="$header\nSet-Cookie: JWT=$JWT; Path=/; HttpOnly"

    body="Status: 200 OK\nLogin successful."
else
    body="Status: 401 Unauthorized\nInvalid credentials."
fi

echo -e "$header\n$body"