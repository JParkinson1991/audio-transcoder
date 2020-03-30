#!/usr/bin/env bash

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