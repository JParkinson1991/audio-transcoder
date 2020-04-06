#!/usr/bin/env bash

# Runs a command file given a command string
#
# Usage:
# run_command <command>
#
# Returns:
# Hard set error status code provided by this function or the run command's exit/return code.
run_command() {
    # Determine command root, ensure it exists
    commandRoot="$APP_ROOT/lib/commands"
    if [[ ! -d "$commandRoot" ]]; then
        error "Failed to find commands at: $commandRoot"
        return 1
    fi

    # Grab and validate command
    command="$1"
    shift # Remove consumed arg
    if [[ -z $command ]]; then
        error "No command provided"
        return 1
    fi

    # Determine command file path, load it
    commandFilePath="$commandRoot/${command//://}.sh"
    if [[ -f "$commandFilePath" ]]; then
        . "$commandFilePath"
        return $?
    fi

    # Default to unhandled command
    error "Unknown command: $command"
    return 1
}