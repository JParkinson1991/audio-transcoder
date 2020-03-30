#!/usr/bin/env bash

# Store the application root
# Do this prior to imports as they may effect the working directory path
APP_ROOT="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd)"

# Define application dependencies
DEPENDENCIES=(lame sox);

# Import all of the required helpers/functions
#
# Importing all files during the bootstrapping of the application ensures all sub commands that are sourced via this
# entry point are able to call on any of the helper functions and utility values file as required without the need
# to import each their required dependencies. Another benefit of this bootstrapping method is that it enables nested
# functions (ie functions requiring other functions), again, they do not need to import their dependencies manually.
importDirs=("$APP_ROOT/lib/util" "$APP_ROOT/lib/functions");
for importDir in ${importDirs[@]}
do
    for file in $(find "$importDir" -name "*.sh")
    do
        source "$file"
    done
done

# Show help screens as necessary
#
# The following command structures will trigger the display of help screens:
#     audio-transcoder.sh (Empty command arguments)
#     audio-transcoder.sh help [command] (Using the help command)
#     audio-transcoder.sh [command] --help (Using the --help flag)
#     audio-transcoder.sh [command] -h (Using the -h flag)
if [ $# == 0 ] || string_contains "$*" --help || string_contains "$*" -h || [[ $1 == "help" ]]; then
    # Used format audio-transcoder.sh help [command]
    # Shift arguments along to determine which command help is required for
    if [ $1 == "help" ]; then
        shift 1
    fi

    # Grab the help command arguments
    helpArgs="$*"

    # If command passed as the following:
    #     audio-transcoder.sh help
    #     audio-transcoder.sh -h
    #     audio-transcoder.sh --help
    # Default to empty help arguments, showing the default help screen
    if [[ $# -eq 0 ]] || [[ $helpArgs == "-h" ]] || [[ $helpArgs == "--help" ]]; then
        helpArgs=""
    fi

    # Command to show helper screen passed, pass to helper method
    show_help "$helpArgs" ":"
    exit $?
fi

# Not viewing help, check for shorthand version call
if [[ "$*" == "--version" ]] || [[ "$*" == "-v" ]]; then
    show_version
    exit 0
fi

# Run the command
run_command "$@"
exit $?