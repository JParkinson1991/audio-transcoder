#!/usr/bin/env bash

if dependency_validate -o ; then
    notice "Dependencies validated, nothing to do."
    exit 0
fi

notice "Installing dependencies"

# Install brew as required
if ! command_exists brew ; then
    notice "Installing homebrew"
    if ! command_exists curl ; then
        error "Missing homebrew install dependency: curl"
        exit 1
    fi

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update homebrew package registry
brew update

# Loop dependencies installing as required
for dependency in ${DEPENDENCIES[@]}
do
    # Ensure command exists
    if command_exists "$dependency" ; then
        notice "$dependency already installed"
    else
        notice "Installing $dependency"
        brew install $dependency
    fi
done

dependency_validate -o
exit $?

