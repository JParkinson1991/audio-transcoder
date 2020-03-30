#!/usr/bin/env bash
# Requires use of ./lib/util/format.sh if used outside of the application binary

# Outputs a standardised error message
#
# Usage:
# error <message>
function error() {
    echo -e "${RED}Error:${RESET} $1"
}

# Outputs a standardised success message
#
# Usage:
# success <message>
function success() {
    echo -e "${GREEN}Success:${RESET} $1"
}

# Outputs a standardised notice message
#
# Usage:
# notice <message>
function notice() {
    echo -e "${BLUE}Notice:${RESET} $1"
}
