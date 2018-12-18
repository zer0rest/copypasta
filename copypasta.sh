#!/bin/bash

# Check if $1 is empty.
if [[ ! "$1" ]]; then 
    echo "No parameters.sh file location was passed as an input, exiting."
    exit
fi

# Include file where server parameters are defined
source $1

# Check if the /tmp/copypasta direcotry exists. If not create it and 
# change it's ownership to $USER
if [ ! -d "$LOCALBASEDIR/copypasta" ];
then
    # Create copypasta/ and give read/write/execute rights only to $USER
    mkdir "$LOCALBASEDIR/copypasta"
    chmod -R 700 "$LOCALBASEDIR/copypasta"
    echo "Directory didn't exist, creating it."
else
    echo "Directory already exists"
fi

# Assign the pasted file type to a variable
TYPE=$(xclip -selection clipboard -t TARGETS -o | grep -m 1 -o -e ^$TEXTFILETYPE -e ^$IMAGEFILETYPE)

# Check if input pasted is text
if [ "$TYPE" = $TEXTFILETYPE ];
then
    # Paste the image or text file to a file at $LOCALBASEDIR
    xclip -selection clipboard -t $TEXTFILETYPE -o > "$LOCALBASEDIR/copypasta/fornow"

    # Create the SHA1 hash of the file and then calculate the base64 of it
    BASE64HASH=$(cat $LOCALBASEDIR/copypasta/fornow | sha256sum | base64)

    # Trunkate the base64 string to the first 5 characters
    TBASE64="$(echo $BASE64HASH | cut -c-5)"

    # Set the new filename based on the base64 string.
    FILENAME="$TBASE64"

    # Rename the file
    mv "$LOCALBASEDIR/copypasta/fornow" "$LOCALBASEDIR/copypasta/$FILENAME"
    cp
# If that's not the case check if input pasted is image
elif [ "$TYPE" = $IMAGEFILETYPE ];
then
    # Paste the image or text file to a file at $LOCALBASEDIR
    xclip -selection clipboard -t $IMAGEFILETYPE -o > "$LOCALBASEDIR/copypasta/fornow.png"
    # Create the SHA1 hash of the file and then calculate the base64 of it.
    BASE64HASH=$(cat $LOCALBASEDIR/copypasta/fornow.png | sha256sum | base64)

    # Trunkate the base64 string to the first 5 characters
    TBASE64="$(echo $BASE64HASH | cut -c-5)"

    # Set the new filename based on the base64 string
    FILENAME="$TBASE64.png"

    # Rename the file
    mv "$LOCALBASEDIR/copypasta/fornow.png" "$LOCALBASEDIR/copypasta/$FILENAME"

# If that's not the case either inform the user and exit
else
    echo "No supported file type was copied, exiting."
    notify-send -a "Copypasta" "No supported file type was copied"
    exit
fi
# scp the file into the remote server
scp "$LOCALBASEDIR/copypasta/$FILENAME" "$HOST:$REMOTEBASEDIR/"

    # Check if scp exited with status code 1. If that's the case, it failed so notify the user.
    if [ $? -eq 0 ]; then 
        echo "succeeded"
        # Add the link into the clipboard
        echo "https://$URL/$FILENAME" | xclip -selection clipboard
        notify-send "Copied into clipboard: https://$URL/$FILENAME" -a "Copypasta"
        
        # Delete the file from $LOCALBASEDIR/copypasta
        rm "$LOCALBASEDIR/copypasta/$FILENAME"
        
    else
        echo "failed"
        notify-send "Failed to upload the paste" -a "Copypasta"
    fi