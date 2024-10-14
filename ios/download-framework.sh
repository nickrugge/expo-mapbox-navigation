#!/bin/bash

binary=$1
url=$2
username=$3
password=$4

function show_usage() {
    echo "Usage: $0 <binary> <url> <username> <password>"
    exit 1
}

function setup_directories() {
    temp_dir=$(mktemp -d)
    frameworks_dir="./Frameworks"
    lockfile="$frameworks_dir/mapbox.lockfile"
    
    mkdir -p "$temp_dir"
    mkdir -p "$frameworks_dir"
}

function is_framework_up_to_date() {
    etag_response=$(curl -I "$url" | grep etag | awk '{print $2}' | tr -d '\r')
    
    if [[ -d "${frameworks_dir}/${binary}.xcframework" ]]; then
        echo "Framework already exists. Checking ETag..."
        stored_etag=$(grep "^$binary:" "$lockfile" | cut -d':' -f2)
        if [[ "$etag_response" == "$stored_etag" ]]; then
            echo "Framework is up to date. Skipping download."
            exit 0
        fi
    fi
}

function download_framework() {
    response=$(curl -u "$username:$password" -o "$temp_dir/${binary}.xcframework.zip" -w "%{http_code}" "$url")

    if [[ "$response" -eq 200 ]]; then
        echo "Download successful. Unzipping..."
        unzip -o "$temp_dir/${binary}.xcframework.zip" -d "$frameworks_dir"
        echo "Framework unzipped to $frameworks_dir."
        echo "$binary:$etag_response" >>"$lockfile"
    else
        echo "Failed to download framework. HTTP status code: $response"
        exit 1
    fi
}

# Main script execution
if [[ -z "$binary" || -z "$url" || -z "$username" || -z "$password" ]]; then
    show_usage
fi

setup_directories
is_framework_up_to_date
download_framework

rm -rf "$temp_dir"
