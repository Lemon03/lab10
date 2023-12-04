#!/bin/bash

echo "Content-type: text/plain"
read POST_DATA

JWT_COOKIE=$(echo "$POST_DATA" | sed 's/JWT=//')

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
