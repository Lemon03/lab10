#!/bin/bash

read POST_DATA
decoded_data=$(echo "$POST_DATA" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')

username=$(echo "$decoded_data" | grep -oE 'username=[^&]+' | cut -d '=' -f2)
password=$(echo "$decoded_data" | grep -oE 'password=[^&]+' | cut -d '=' -f2)

# Output headers
echo "Content-type: text/plain"
echo ""

# Output username and password for debugging
echo "Username: $username"
echo "Password: $password"