#!/usr/bin/env bash

# Validate dependencies
if ! dependency_validate -o ; then
    exit $?
fi

# Set default values
CREATE_SPECTRALS=""
FORCE=""
FORMATS=(FLAC 320 V0 V2)
INTERACTIVE=0 #true
RECURSIVE=1 # false

# Process CLI arguments
positional=()
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
	    -e|--formats)
	        formatString=$(echo "$2" | tr '[:lower:]' '[:upper:]')
	    	FORMATS=(${formatString/,/ })
	    	shift # past argument
	    	shift # past value
	    	;;
        -f|--force)
	        FORCE="-f"
	        shift # past argument
	        ;;
        -r|--recursive)
            RECURSIVE=0 #true
            shift
            ;;
        -s|--spectrals)
            CREATE_SPECTRALS="-s"
            shift # past argument
            ;;
    	-y|--non-interactive)
			INTERACTIVE=1 #false
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

# Store input directory, validate it
INPUT_DIR="${1/#\~/$HOME}"
if [[ -z "$INPUT_DIR" ]]; then
	error "No input directory provided"
	exit 1
elif [[ ! -d "$INPUT_DIR" ]]; then
	error "Failed to find input directory at: $INPUT_DIR"
	exit 1
fi


# Store output directory, validate it
OUTPUT_DIR="${2/#\~/$HOME}"
if [[ -z "$OUTPUT_DIR" ]]; then
	error "No output directory provided"
	exit 1
fi

# Interactive mode
if [[ $INTERACTIVE -eq 0 ]]; then
    echo "---"
	notice "Process details"
	echo "Input Directory: $INPUT_DIR"
	echo "Output Directory: $OUTPUT_DIR"
	echo "Formats: ${FORMATS[*]}"
	if [[ $CREATE_SPECTRALS != "" ]]; then
	    echo "Create Spectrals: Enabled"
    else
        echo "Create Spectrals: Disabled"
	fi
    if [[ $FORCE != "" ]]; then
        echo "Force Creation: Enabled"
    else
        echo "Force Creation: Disabled"
    fi
    if [[ $RECURSIVE -eq 0 ]]; then
        echo "Recursive Mode: Enabled"
    else
        echo "Recursive Mode: Disabled"
    fi
    echo "---"
	confirm
fi

IFS=$'\n'

# Handle Recursive Processing
if [[ $RECURSIVE -eq 0 ]]; then
    # Grab the parent of the input directory
    # This will be removed from found files,
    inputBasePath=$(dirname "$INPUT_DIR")

    for childDirectory in $(find "$INPUT_DIR" -type d -mindepth 1 -maxdepth 1)
    do
        notice "Processing Directory: $childDirectory";

        # Clean the directory name
        dirNameClean=$(clean_directory_name $(basename "$childDirectory"))
        outputDir="$OUTPUT_DIR/$dirNameClean"

        for format in ${FORMATS[@]}
        do
            echo "---"
            notice "Transcoding to: $format"

            # Determine output directory
            if [[ $format == "FLAC" ]]; then
                formatOutputDir="$outputDir [FLAC]"
            else
                formatOutputDir="$outputDir [MP3 $format]"
            fi

            echo "Output Directory: $formatOutputDir"
            transcode_directory "$childDirectory" "$formatOutputDir" "$format" $FORCE $CREATE_SPECTRALS
        done
    done
# Handle Single Directory Processing
else
    dirNameClean=$(clean_directory_name $(basename "$INPUT_DIR"))
    outputDir="$OUTPUT_DIR/$dirNameClean"

    for format in ${FORMATS[@]}
    do
        echo "---"
        notice "Transcoding to: $format"

         # Determine output directory
        if [[ $format == "FLAC" ]]; then
            formatOutputDir="$outputDir [FLAC]"
        else
            formatOutputDir="$outputDir [MP3 $format]"
        fi

        echo "Output Directory: $formatOutputDir"
        transcode_directory "$INPUT_DIR" "$formatOutputDir" "$format" $FORCE $CREATE_SPECTRALS
    done
fi

echo "---"
notice "Complete, view previous for errors"
exit 0
