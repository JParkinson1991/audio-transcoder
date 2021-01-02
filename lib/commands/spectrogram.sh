#!/usr/bin/env bash

# Set Defaults
INLINE=1 #false
IMGCAT_DEPTH=""
ZOOMED=0 #false

# Process CLI arguments
positional=()
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
	    -d|--imgcat-depth)
	        IMGCAT_DEPTHS="--depth=$2"
	        shift # past argument
	        shift # past value
	        ;;
	    -i|--inline)
	        INLINE=0
	        shift # past argument
	        ;;
	    -z|--zoomed)
	        ZOOMED=0;
	        shift # past argument
	        ;;
	    *)
			# Unhandled options treated as positional arguments
	   		positional+=("$1")
	    	shift # past argument
	    ;;
	esac
done
set -- "${positional[@]}" # restore positional parameters

# Non inline output
# Nice and simple
if [[ $INLINE -eq 1 ]]; then
    outputDir="$2"
    if [[ -z "$2" ]]; then
        outputDir="$(pwd)"
    fi

    create_spectrograms "$1" "$outputDir" $ZOOMED
    exit $?
fi

# Inline output from here
# Ensure imgcat exists
if ! command_exists "imgcat" ; then
    error "Please install imgcat to view inline spectrograms"
    echo "Download from here: https://github.com/eddieantonio/imgcat"
    exit 1
fi

# Create temp output dir, to store files
tmpOutputDir="$(pwd)/.spectrogramstemp";
create_spectrograms "$1" "$tmpOutputDir" $ZOOMED
if [[ $? -eq 0 ]]; then
    IFS=$'\n'

    for spectrogram in $(find "$tmpOutputDir" -type f -name "*.png" ! -name "*.zoomed.png")
    do
        imgcat $IMGCAT_DEPTH "$spectrogram"
    done

    if [[ $ZOOMED ]]; then
        for spectrogram in $(find "$tmpOutputDir" -type f -name "*.zoomed.png" ! -name ".png")
        do
            imgcat $IMGCAT_DEPTH "$spectrogram"
        done
    fi
fi

rm -rf "$tmpOutputDir"
exit 0