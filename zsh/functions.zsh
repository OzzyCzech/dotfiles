#!/bin/bash

# concat multiple video files to single one
# params video-concat *.MP4 output.mp4
function video-concat() {
  ffmpeg -f concat -safe 0 -i <(for f in ${@:1:${#}-1}; do echo "file '$PWD/$f'"; done) -c copy $_
}

# rename multimedia images, videos, audios with exiftool to date time format¨
# rename-multimedia -ext jpg .
function rename-multimedia() {
  exiftool -r -m -d "%Y-%m-%d %H.%M.%S%%-c.%%le" \
    "-filename<FileInodeChangeDate" \
    "-filename<ModifyDate" \
    "-filename<CreateDate" \
    "-filename<CreationDate" \
    "-filename<DateTimeOriginal" \
    -if '$filename !~ /^\./' \
    -ext jpg -ext jpeg -ext png -ext gif -ext tif -ext tiff \
    -ext mp4 -ext avi -ext mov -ext mkv -ext m4v \
    -ext raf \
    "$@"
}

# Rename all files in folder to sequential filenames
function rename-sequenced() {
  r=$'\e[31m'  nl=$'\n'  n=$'\e[0m' files=$(ls -1 | wc -l)
  read -r -p "${r}All ${files} files in folder '$(pwd)' will be sequentially renamed${nl}${n}Are you sure? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    rename --counter-format 000001 --lower-case --keep-extension --expr='$_ = "$N" if @EXT' *
  fi
}

# Clean up drive before unmount
function cleandrive() {
  if [ -n "$1" ] && [ -d "/Volumes/$1/" ]; then
    read -r -p "Clean /Volumes/$1/ and unmount? [y/N] " response
      if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        find "/Volumes/$1/" -name "._*" -type f -delete
        find "/Volumes/$1/" -name "*.DS_Store" -type f -ls -delete
        rm -rf "/Volumes/$1/.Spotlight-V100/"
        rm -rf "/Volumes/$1/.Trashes/"
        diskutil unmount "/Volumes/$1/"
        echo "Done..."
      fi
  else
    echo "Drive '$1' missing"
  fi
}

# Convert all images to HEIC
# example: heic *.jpg
function heic() {
  for i in "$@"; do sips -s format heic -s formatOptions 80 "$i" --out "${i%.*}.heic";done
}

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

# Base64 encode file
function b64() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}