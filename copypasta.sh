#!/bin/bash

# Check if $1 is empty.
if [[ ! "$1" ]]; then 
    echo "No parameters.sh file location was passed as an input, exiting."
    exit
fi

# Include file where server parameters are defined
source $1

# Assign the pasted file type to a variable
TYPE=$(xclip -selection clipboard -t TARGETS -o | grep -m 1 -o -e ^$TEXTFILETYPE -e ^$IMAGEFILETYPE)

# Check if input pasted is text
if [ "$TYPE" = $TEXTFILETYPE ];
then
    # Paste the image or text file to a file at $LOCALBASEDIR
    xclip -selection clipboard -t $TEXTFILETYPE -o > "$LOCALBASEDIR/fornow"
    # Create the SHA1 hash of the file and then calculate the base64 of it
    BASE64HASH=$(cat $LOCALBASEDIR/fornow | sha256sum | base64)

    # Trunkate the base64 string to the first 5 characters
    TBASE64="$(echo $BASE64HASH | cut -c-5)"

    # Set the new filename based on the base64 string.
    FILENAME="$TBASE64"
    # Rename the file
    mv "$LOCALBASEDIR/fornow" "$LOCALBASEDIR/$FILENAME"
    
# If that's not the case check if input pasted is image
elif [ "$TYPE" = $IMAGEFILETYPE ];
then
    # Paste the image or text file to a file at $LOCALBASEDIR
    xclip -selection clipboard -t $IMAGEFILETYPE -o > "$LOCALBASEDIR/fornow.png"
    # Create the SHA1 hash of the file and then calculate the base64 of it.
    BASE64HASH=$(cat $LOCALBASEDIR/fornow.png | sha256sum | base64)

    # Trunkate the base64 string to the first 5 characters
    TBASE64="$(echo $BASE64HASH | cut -c-5)"

    # Set the new filename based on the base64 string
    FILENAME="$TBASE64.png"

    # Rename the file
    mv "$LOCALBASEDIR/fornow.png" "$LOCALBASEDIR/$FILENAME"

# If that's not the case either inform the user and exit
else
    echo "No supported file type was copied, exiting."
    notify-send -a "Copypasta" "No supported file type was copied"
    exit
fi
# scp the file into the remote server
scp "$LOCALBASEDIR/$FILENAME" "$HOST:$REMOTEBASEDIR/"
# echo "$?"
    # Check if scp exited with status code 1. If that's the case, it failed so notify the user.
    if [ $? -eq 0 ]; then 
        echo "succeeded"
        # Add the link into the clipboard
        echo "https://$URL/$FILENAME" | xclip -selection clipboard
        notify-send "Copied into clipboard: https://$URL/$FILENAME" -a "Copypasta"
    else
        echo "failed"
        notify-send "Failed to upload the paste" -a "Copypasta"
    fi