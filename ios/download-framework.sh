#!/bin/bash

# Read arguments from the command line and validate them
binary=$1
url=$2
username=$3
password=$4

# Validate input arguments
if [[ -z "$binary" || -z "$url" || -z "$username" || -z "$password" ]]; then
    echo "Usage: $0 <binary> <url> <username> <password>"
    exit 1
fi

echo $binary
echo $url
echo $username
echo $password

temp_dir=$(mktemp -d)
frameworks_dir="./Frameworks"

# Create temp download directory if it doesn't exist
mkdir -p "$temp_dir"

# Create Frameworks directory if it doesn't exist
mkdir -p "$frameworks_dir"

# Check if the framework file already exists in the Frameworks directory
if [[ -f "${frameworks_dir}/${binary}.xcframework.zip" ]]; then
    echo "Framework already exists. Skipping download."
    exit 0
fi

# Make a request to the download URL with basic authentication
response=$(curl -u "$username:$password" -o "$temp_dir/${binary}.xcframework.zip" -w "%{http_code}" "$url")

# If the request is successful, write the response body to the framework zip file
if [[ "$response" -eq 200 ]]; then
    echo "Download successful. Unzipping..."
    unzip -o "$temp_dir/${binary}.xcframework.zip" -d "$frameworks_dir"
    echo "Framework unzipped to $frameworks_dir."
else
    echo "Failed to download framework. HTTP status code: $response"
    exit 1
fi

# Clean up temporary files
rm -rf "$temp_dir"