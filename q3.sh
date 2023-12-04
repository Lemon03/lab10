#!/bin/bash

# Print the content type header
echo "Content-type: text/plain"
echo

# Get the JWT from the browser's cookie
JWT_COOKIE=$(echo "${HTTP_COOKIE}" | grep -o 'd2lJWT=[^;]*' | cut -d '=' -f2)

# Function to validate the JWT
validate_jwt() {
    local jwt=$1

    local header=$(echo $jwt | cut -d "." -f1)
    local payload=$(echo $jwt | cut -d "." -f2)
    local signature=$(echo $jwt | cut -d "." -f3)

    if [[ ! -z "$header" ]] && [[ ! -z "$payload" ]] && [[ ! -z "$signature" ]]; then
        return 0 
    else
        return 1 
    fi
}

# Validate the JWT
if validate_jwt "$JWT_COOKIE"; then
    echo "Status: 200 OK"
    echo "Valid JWT provided."
else
    echo "Status: 401 Unauthorized"
    echo "Invalid or no JWT provided."
fi
