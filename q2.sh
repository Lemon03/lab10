#!/bin/bash

# Read POST data
POST_DATA=$(cat)

# Extract boundary from CONTENT_TYPE environment variable
BOUNDARY=$(echo $CONTENT_TYPE | sed 's/.*boundary=\(.*\)/\1/')

# Process POST data to extract username and password
username=$(echo "$POST_DATA" | awk -v RS="--$BOUNDARY" '/name="username"/ {getline; getline; print}' | tr -d '\r')
password=$(echo "$POST_DATA" | awk -v RS="--$BOUNDARY" '/name="password"/ {getline; getline; print}' | tr -d '\r')

# Output the parsed data
echo "Content-type: text/plain"
echo ""
echo "Username: $username"
echo "Password: $password"
