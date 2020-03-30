#!/usr/bin/env bash

# Determines all script dependencies are met
#
# Usage:
# dependency_validate
dependency_validate() {
    # Return value, 0 pass, 1 fail
    return=0

    showOutput=1
    while getopts ":o" o; do
        case "${o}" in
            o)
                showOutput=0
                ;;
            *)
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ $showOutput -eq 0 ]]; then
        notice "Validating dependencies"
    fi

    # Validate dependencies
    for dependency in ${DEPENDENCIES[@]}
    do
        # Ensure command exists
        if ! command_exists "$dependency" ; then
            if [[ $showOutput -eq 0 ]]; then
                error "Missing required dependency: $dependency"
            fi
            return=1
        elif [[ $showOutput -eq 0 ]]; then
            success "Dependency installed: $dependency"
        fi
    done

    return $return
}