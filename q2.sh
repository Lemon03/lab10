#!/bin/bash

echo "Content-type: text/plain"

read POST_DATA

username=$(echo "$POST_DATA" | grep -oE 'username=[^&]+' | sed 's/username=//')
password=$(echo "$POST_DATA" | grep -oE 'password=[^&]+' | sed 's/password=//')


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

    # Set the JWT in a cookie
    echo "Set-Cookie: JWT=$JWT; Path=/; HttpOnly"
    echo "Status: 200 OK"
    echo "Login successful."
else
    echo "Status: 401 Unauthorized"
    echo "Invalid credentials."
fi
