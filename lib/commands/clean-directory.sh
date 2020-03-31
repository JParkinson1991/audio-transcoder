#!/usr/bin/env bash

VERBOSE=0 # Verbose output, default true

# If no arguments passed
if [[ $# == 0 ]]; then
    error "No paths provided"
    exit 1
fi

# Disable verbose output for single arguments
if [[ $# == 1 ]]; then
    VERBOSE=1
fi

# Loop and clean arguments
for path in "$@"
do
    dirName=$(basename "$path")
    dirNameClean=$(clean_directory_name "$dirName")

    # Handle output
    if [[ $VERBOSE -eq 1 ]]; then
        echo "$dirNameClean"
    else
        notice "Processing" "$dirName"
        echo "  Directory Name: $dirName"
        echo "  Clean: $dirNameClean"
    fi
done

exit 0