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
OUTPUT_ROOT="$(pwd)"
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
        -o|--output-root)
            OUTPUT_ROOT="$(echo ${2/#\~/$HOME} | sed 's|/*$||')"
            shift #past argument
            shift #past value
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

# Interactive mode
if [[ $INTERACTIVE -eq 0 ]]; then
    echo "---"
	notice "Process details" ""
	echo "Output Root: $OUTPUT_ROOT"
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

# Loop and clean arguments
for inputDir in "$@"
do
    # Remove trailing slash from input directory
    inputDir="$(echo $inputDir | sed 's|/*$||')"

    # Ensure input directory exists
    if [[ ! -d "$inputDir" ]]; then
        waning "Skipping" "Failed to find: $inputDir"
        continue
    fi

    # Determine transcode directories
    # Flat mode: Input directory only
    # Recursive, first child directories of input directory
    transcodeDirs="$inputDir"
    if [[ $RECURSIVE -eq 0 ]]; then
        # Output processing directory notice
        notice "Recursively Processing" "$inputDir"

        transcodeDirs=$(find "$inputDir" -type d -mindepth 1 -maxdepth 1)
    fi

    # Loop over and transcode files within all required directories
    for transcodeDirectory in "${transcodeDirs[@]}"
    do
        notice "Processing Directory" "$transcodeDirectory"

        # Clean directory name for use as output name
        transcodeDirectoryNameClean=$(clean_directory_name $(basename "$transcodeDirectory"))
        outputDirectory="$OUTPUT_ROOT/$transcodeDirectoryNameClean"

        for format in ${FORMATS[@]}
        do
            echo "---"
            notice "Transcoding to" "$format"

            # Determine output directory full name
            if [[ $format == "FLAC" ]]; then
                formatOutputDir="$outputDirectory [FLAC]"
            else
                formatOutputDir="$outputDirectory [MP3 $format]"
            fi

            # Show the output directory
            echo "Output Directory: $formatOutputDir"

            # If interactive allow user to change output directory name
            if [[ $INTERACTIVE -eq 0 ]]; then
                while true;
                do
                    read -n 1 -p "Change output directory name? [y/N] " yn
                    case $yn in
                        [Yy]* )
                            echo ""
                            while true;
                            do
                                read -p "Directory name: " userDirName
                                if [[ -z $userDirName ]]; then
                                    echo "No directory name provided, default will be used"
                                elif [[ -d "$OUTPUT_ROOT/$userDirName" && "$FORCE" == "" ]]; then
                                    echo "Directory exists at: $OUTPUT_ROOT/$userDirName"
                                    echo "Please use a different name"
                                    continue
                                else
                                    formatOutputDir="$OUTPUT_ROOT/$userDirName"
                                fi

                                echo "New Output Directory: $formatOutputDir"
                                break
                            done
                            echo ""
                            break;;
                        [Nn]* )
                            echo ""
                            break;;
                        * )
                            # Only output newline if enter key pressed
                            if [[ ! -z $yn ]]; then
                                echo ""
                            fi
                            break;;
                    esac
                done
            fi
            transcode_directory "$transcodeDirectory" "$formatOutputDir" "$format" $FORCE $CREATE_SPECTRALS
        done
    done
done

echo "---"
notice "Complete, view previous for errors"
exit 0