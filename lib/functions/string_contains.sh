#!/usr/bin/env bash

# Determines if a string contains a given sub string
#
# Usage:
# string_contains <haystack> <needle>
#
# Returns:
# Int representations of true/false
string_contains() {
    if [[ $1 == *"${2}"* ]]; then
        return 0; #true
    else
        return 1; #false
    fi
}
