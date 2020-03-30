#!/usr/bin/env bash

# Shows help pages for the given command string
#
# Usage:
# show_help [command]
#
# If no command passed the default help screen is displayed
#
# Returns:
# The status code of help screen load useful if consumers plan to exit post render
show_help() {
    # Ensure the expected help root directory exists
    helpRoot="$APP_ROOT/help"
    if [[ ! -d "$helpRoot" ]]; then
        error "Failed to find help screens at: $helpRoot"
        return 1
    fi

    # Parse help command
    command="$1"

    # If no commands received show default help screen
    if [[ -z $command ]]; then
        cat "$helpRoot/audio-transcoder.txt"
        return 0
    fi

    # Determine expected help file path
    helpFilePath="$helpRoot/${command//://}.txt"
    if [[ -f "$helpFilePath" ]]; then
        cat "$helpFilePath"
        return 0
    fi

    # Failed to find help screen for command
    error "Unknown Command: $command"
    notice "Showing default help screen"
    echo ""
    cat "$helpRoot/audio-transcoder.txt"
    return 1
}