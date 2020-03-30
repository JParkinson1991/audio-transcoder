#!/usr/bin/env bash

# Creates spectrogram images from a given file saving them at a provided output root
#
# Usage:
# create_spectrogram <input file> <output dir> <zoomed>
#
# zoomed = 1 | Do not create zoomed spectrogram
# zoomed = 0 | Create zoomed spectrogram
create_spectrograms() {
    INPUT_FILE="${1/#\~/$HOME}"
    if [[ -z "$INPUT_FILE" ]]; then
        error "No input file provided"
        exit 1
    elif [[ ! -f "$INPUT_FILE" ]]; then
        error "Failed to fine input file at: $INPUT_FILE"
        exit 1
    fi

    OUTPUT_DIR="${2/#\~/$HOME}"
    if [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR=$(dirname "$INPUT_FILE")
    fi

    ZOOMED=$3
    if [[ -z "$ZOOMED" ]]; then
        ZOOMED=0
    fi

    # Create output dir as required
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        mkdir -p $OUTPUT_DIR
    fi

    inputFileName=$(basename "$INPUT_FILE")
    inputFileExtension="${inputFileName##*.}"
    OUTPUT_FILE=$OUTPUT_DIR/"${inputFileName/.$inputFileExtension/.png}"

    sox "$INPUT_FILE" -n spectrogram -o "$OUTPUT_FILE"
    success "Created spectrogram at: $OUTPUT_FILE"

    if [[ $ZOOMED -eq 0 ]]; then
        sox "$INPUT_FILE" -n remix 1 spectrogram -z 120 -w Kaiser -S 0:25 -d 0:04 -o "${OUTPUT_FILE/.png/.zoomed.png}"
        success "Created zoomed spectrogram at: ${OUTPUT_FILE/.png/.zoomed.png}"
    fi
}