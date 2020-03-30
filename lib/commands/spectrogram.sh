#!/usr/bin/env bash

zoomed=1 #false
while getopts ":z" o; do
    case "${o}" in
        z)
            zoomed=0 #true
            ;;
        *)
            ;;
    esac
done
shift $((OPTIND-1))

create_spectrograms "$1" "$2" $zoomed


