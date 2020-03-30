#!/usr/bin/env bash

# Transcodes all files in a directory
#
# Usage:
# transcode_directory <input_dir> <output_dir> <format> [options]
#
# Options:
# -f | Force create, delete any existing directories
# -s | Spectrals, create spectrals for transcoded files
transcode_directory() {
    local inputDir=$1
    local outputDir=$2
    local format=$3

    # Determine force and spectral values
    if string_contains "$*" "-f"; then
        local force=0 #true
    else
        local force=1 #false
    fi
    if string_contains "$*" "-s"; then
        local createSpectrals=0 #true
    else
        local createSpectrals=1 #false
    fi

    # If output directory exists, skip processing
    if [[ -d "$outputDir" ]]; then
        if [[ $force -eq 1 ]]; then
            error "$outputDir already exists, skipping"
            return 1
        else
            rm -rf "$outputDir"
        fi
    fi

    #For every file found in the child directory
    for file in $(find "$inputDir" -type f ! -path '*/\.*' ! -name "*.log" ! -name "*.cue")
    do
        filename=$(basename "$file")
        extension="${filename##*.}"
        outputFilePath="$outputDir/${file/"$inputDir"\//}"

        # Create the required directories for the file
        mkdir -p $(dirname "$outputFilePath")

        # Simply copy over files that are not FLAC
        if [[ $extension != "flac" ]]; then
            cp "$file" "$outputFilePath"
            continue
        fi

        # From this point on we know we're dealing with .flac files
        if [[ $format == "FLAC" ]]; then
            fileBitsPerSample=$(sox --i -b "$file")
            fileSampleRate=$(sox --i -r "$file")

            # Only downsample supported flacs
            # > 16 bit or > 48000 sample rate
            if [[ $fileBitsPerSample -gt 16 ]] || [[ $fileSampleRate -gt 48000 ]]; then
                # Determine needed sample rate
                if [[ $(expr $fileSampleRate % 44100) -eq 0 ]]; then
                    newSampleRate=44100
                elif [[ $(expr $fileSampleRate % 48000) -eq 0 ]]; then
                    newSampleRate=48000
                else
                    error "Unable determine appropriate sample rate for $file. Actual sample rate $fileSampleRate"
                    rm -rf "$outputDir"
                    return 1
                fi

                # Transcode the file
                echo "Resampling: $file"
                sox "$file" -G -b 16 "$outputFilePath" rate -v -L "$newSampleRate" dither
                echo "Created: $outputFilePath"
            else
                error "Refusing to transcode flac with sample rate <= 16 and sample rate <= 48000"
                rm -rf "$outputDir"
                return 1
            fi
        else
            # Compression factor driven documentation available here
            # http://manpages.ubuntu.com/manpages/bionic/man7/soxformat.7.html
            if [[ $format == "320" ]]; then
                compressionFactor=320.01
            elif [[ $format == "V0" ]]; then
                compressionFactor=-0.01
            elif [[ $format == "V2" ]]; then
                compressionFactor=-2.01
            else
                error "Unhandled format: $format"
                rm -rf "$outputDir"
                return 1
            fi

            # Update the output file path to be an mp3
            outputFilePath=${outputFilePath/.flac/.mp3}

            echo "Transcoding: $file"
            sox "$file" -C $compressionFactor "$outputFilePath"
            echo "Created: $outputFilePath"
        fi

        if [[ $createSpectrals -eq 0 ]]; then
            # Create spectrograms and zoomed
            create_spectrograms "$outputFilePath" "$outputDir/spectrals"
        fi
    done
}