#!/usr/bin/env bash

# Determines if a given command exists and executable
#
# Usage:
# command_exists <command>
command_exists() {
    if [ -x "$(command -v $1)" ]; then
        return 0 #command exists
    else
        return 1 #command doesn't exist
    fi
}
