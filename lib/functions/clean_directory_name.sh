#!/usr/bin/env bash

# Cleans a directory name removing any metadata about the source file format
#
# For example, if using the source file directory name to drive the transcode output directory name ideally you do
# not want to be mixing meta descriptions. For example, if the source directory name contains the fact the files stored
# within it are 'FLAC 24Bit', you do not want this to be carried across to a transcode output directory as that directory
# does not store files of that type.
#
# This function removes all file type/format meta from a directory name so that it can be used safely in naming of
# transcode directories.
#
# Usage:
# clean_directory_name <directory name>
# VARIABLE=$(clean_directory_name <directory name>)
clean_directory_name() {
    local dirName=$1

    # Remove non printable characters from the directory name
    # Passes non printable characters to sed will cause it to error out
    # Are non prinable characters going to be missed? Unlikely.
    dirName=$(iconv -c -f utf-8 -t ascii <<< "$dirName")

    # Forgive the nastiness of this replacement
    # We're trying to catch all eventualities
    echo $(sed '
        s|FLAC-24BIT||g;
        s|flac-24bit||g;
        s|FLAC-24||g;
        s|flac-24||g;
        s|FLAC_24||g;
        s|flac_24||g;
        s|FLAC 24||g;
        s|flac 24||g;
        s|FLAC24||g;
        s|flac24||g;
        s|flac||g;
        s|FLAC||g;
        s|24BIT||g;
        s|24Bit||g;
        s|24bit||g;
        s|24-bit||g;
        s|24-96||g;
        s|-96||g;
        s|24-44.1||g;
        s|-44.1||g;
        s|\[24\]||g;
        s|16-44||g;
        s|[0-9]*kHz||g;
        s|--*|-|g;
        s|__*|_|g;
        s|_| |g;
        s|-*$||g;
        s|  *| |g;
        s|&\]|\]|g;
        s|&\\)|\\)|g;
        s|&}|}|g;
        s|-\]|\]|g;
        s|-\\)|\\)|g;
        s|-}|}|g;
        s| \]|\]|g;
        s| \\)|\\)|g;
        s| }|}|g;
        s| \]|\]|g;
        s|-}|}|g;
        s|\[\]||g;
        s|\\(\\)||g;
        s|{}||g;
        s|[ \t]*$||g;
    ' <<< "$dirName")

    # Removed
    # s|- ||g;
}