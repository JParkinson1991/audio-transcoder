# Audio Transcoder

Bash CLI application for transcoding/downsampling FLAC files to MP3.

Available transcode operations:

| Input Format | Output Format  |
|--|--|
| FLAC (> 24Bit \| > 48000khz) | FLAC 16Bit |
| FLAC | MP3 320 CBR |
| FLAC | MP3 V0 VBR |
| FLAC | MP3 V2 VBR |

This application can also be used to generated `spectrograms` for audio files.

The aim of this application is to wrap and abstract away the complexities of the transcode process providing sensible 
defaults in order to keep the command interface as simple as possible for the end user. If a more granular configuration
of transcode command is required then it's recommended to use [Sox][sox]

The terminal examples used throughout are denoted by
- `#` Comments, read only
- `$` Command prompt, execute
- `>` Command output, read only

## Getting Started

Audio Transcoder provides a simple bash script entry point which can be used to trigger all internal operations.

### Requirements

The following applications are required
- [Sox][sox]

Optional:
- [imgcat][imgcat]
  - If you are generating inline spectrograms

### Installing

To install, simply clone/download this repo adding its executable to `$PATH`

Cloning the repository

```
# Replace INSTALL_PATH with actual installation path
git clone https://github.com/JParkinson1991/audio-transcoder.git INSTALL_PATH
```

Adding the executable to `$PATH`

```
# Vew current path directories
$ echo $PATH
> /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Option 1: Link executable to existing $PATH directory
# Replace INSTALL_PATH with installation path
# Use a directory as output above for the second argument
$ ln -s INSTALL_PATH/bin/audio-transcoder.sh /usr/local/bin/audio-transcoder
$ chmod +x /usr/local/bin/audio-transcoder

# Option 2: Add bin directory to $PATH
# Add the following to your profile file: .bashrc, .bash_profile, .zshrc etc
# Replace INSTALL_PATH with installation path
export PATH="INSTALL_PATH/bin:$PATH"
```

### Validating the installation

After installation using one of the above methods try executing the version command

```
# If installed via 'Option 1'
$ audio-transcoder -v
> 1.0.0

# If install via 'Option 2'
$ audio-transcoder.sh -v
> 1.0.0
```

## Commands

```
# Clean directory names - removing all audio format metadata
$ audio-transcoder clean-directory <path...>

# Dependency installation for MacOS via homebrew
$ audio-transcoder dependency:install:mac

# Validate dependencies installed
$ audio-transcoder dependency:validate

# View the help screens
$ audio-transcoder help [command]

# Transcode FLAC files
$ audio-transcoder transcode [options] <input dir...>

# Generate spectrograms from audio files
$ audio-transcoder spectrogram [options] <input file> [output dir]

# View the application version
$ audio-transcoder version
```

### Viewing detailed help screens

To view the application help screen

```
$ audio-transcoder
$ audio-transcoder help
$ audio-transcoder -h
$ audio-transcoder --help
```

To view detailed help screens for a given command the following can be run

```
$ audio-transcoder help [command]
$ audio-transcoder [command] -h
$ audio-transcoder [command] --help
```

## Transcoding 

Input directories can be treat as a single flac containing directory or the parent directory of multiple flac
containing directories. To enable processing as a parent, use the recursive mode. When recursive mode is enabled
the first child directories of each input directory will have it's content transcoded as required.

During transcode, only flac files will be recognised within the provided input directories, no other files will be
used as a transcode source.

The transcode process automatically generates directory names to store the transcoded files (one per format) in both 
standard and recursive contexts, these directory names can be overridden on a per process basis when not in non 
interactive mode. Directory names are generated using the outputs from the `clean-directory` command.

All other files found within the input directory will be mirrored into the generated output directory except for
.cue and .log files. It is assumed that these files exists as part of a CD rip and therefore are not relevant to the
transcode outputs. Note if you have mixed directories, mp3's and flac's in the same place the transcoder process
will carry these across, it is not the job of this application to manage file organization.

Spectrograms can be generated for each of the transcoded files as needed.

Multiple input directories can be passed to trigger simultaneous with a single command.

It is strongly recommended to view the help screen for the `transcode` command for detailed information on options
and arguments.

```
$ audio-transcoder help transcode
```

### Transcoding a FLAC directory

```
# The following command will:
#   Transcode the directory: ~/music
#   Transcode to: MP3 320, MP3 V0, MP3 V2 (-e) 
#   Generate spectrograms for the transcoded files (-s)
#   Overwrite any existing directorys while transcoding (-f)
#   Output the transcodes to: ~/transcoded
$ audio-transcoder transcode -e 320,V0,V2 -s -f "~/music" "~/transcoded"
```

### Recursively transcoding multiple FLAC directories

```
# The following command will:
#    Recursively transcode the directory: ~/music (-r)
#    Transcode to: MP3 320 (-e)
#    Output the transcodes to: ~/transcoded
$ audio-transcoder transocder -e 320 -r "~/music" "~/transcoded"
```

## Versioning

We use [Semantic Versioning](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/JParkinson1991/audio-transcoder/tags). 

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* [Sox][sox] - Thanks for doing all the heavy lifting.

[sox]: http://sox.sourceforge.net/ 
[imgcat]: https://github.com/eddieantonio/imgcat