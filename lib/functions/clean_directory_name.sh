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
    echo $(sed '
        s|flac||g;
        s|FLAC||g;
        s|\[24-96\]||g;
        s|\[24\]||g;
        s|\[\]||g;
        s|\(\)||g;
        s|{}||g;
        s|[ \t]*$||g;
    ' <<< "$1")
}