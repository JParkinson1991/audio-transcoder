#!/usr/bin/env bash

# Determine source directory of this script.
# Required to build import paths etc etc.
# Ensure symlinks are followed when determining script source path
# Taken  from: https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself/246128#246128
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" >/dev/null 2>&1 && pwd )"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" >/dev/null 2>&1 && pwd )"

# Store APP_ROOT after SCRIPT_DIR resolved
# Do this prior to imports as they may effect the working directory path
APP_ROOT=$(dirname $SCRIPT_DIR)

# Define application dependencies
DEPENDENCIES=(sox);

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
if [[ $# == 0 ]] || string_contains "$*" --help || string_contains "$*" -h || [[ $1 == "help" ]]; then
    # Used format audio-transcoder.sh help [command]
    # Shift arguments along to determine which command help is required for
    if [ $1 == "help" ]; then
        helpFirst=0 # set flag for edgecases ie help -h | help --h
        shift 1
    fi

    # If command passed as the following:
    #     audio-transcoder.sh help
    #     audio-transcoder.sh -h
    #     audio-transcoder.sh --help
    # Default to empty help arguments, showing the default help screen
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    elif [[ "$*" == "-h" ]] || [[ "$*" == "--help" ]]; then
        # Capture edge case of viewing help -h | help --help
        if [[ -z $helpFirst ]]; then
            show_help
        else
            show_help "help"
        fi
        exit 0
    fi

    # Cleanup help string, extract command portion
    helpArgs=${*//--help}
    helpArgs=${helpArgs//-h}
    helpArgs=$(echo $helpArgs | sed 's|^ *||g; s| *$||g;');

    # Command to show helper screen passed, pass to helper method
    show_help "$helpArgs"
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