#!/usr/bin/env bash

# Triggers a confirmation prompt
#
# Usage:
# confirm [message]
confirm() {
    message="Happy to proceed?"
    if [[ ! -z "$1" ]]; then
        message="$1"
    fi

    while true;
    do
        read -n 1 -p "$message [y/N] " yn
        case $yn in
            [Yy]* ) echo "" && break;;
            [Nn]* ) echo "" && exit;;
            * ) echo "" && exit;;
        esac
    done
}
