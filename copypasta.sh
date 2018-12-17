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
    xclip -selection clipboard -o > "$LOCALBASEDIR/fornow"

    # Create the SHA1 hash of the file
    SHA1SUM=$(sha1sum /tmp/fornow | awk '{printf $1}')

    # Trunkate the hash to the first 5 characters
    THASH="$(echo $SHA1SUM | cut -c-5)"

    # Set the new filename based on the trunkated hash
    HASHFILENAME="$THASH"

    # Rename the file
    mv "$LOCALBASEDIR/fornow" "$LOCALBASEDIR/$HASHFILENAME"

# If that's not the case check if input pasted is image
elif [ "$TYPE" = $IMAGEFILETYPE ];
then
    # Paste the image or text file to a file at $LOCALBASEDIR
    xclip -selection clipboard -t $IMAGEFILETYPE -o > "$LOCALBASEDIR/fornow.png"

    # Create the SHA1 hash of the file
    SHA1SUM=$(sha1sum /tmp/fornow.png | awk '{printf $1}')

    # Trunkate the hash to the first 5 characters
    THASH="$(echo $SHA1SUM | cut -c-5)"

    # Set the new filename based on the trunkated hash
    HASHFILENAME="$THASH.png"

    # Rename the file
    mv "$LOCALBASEDIR/fornow.png" "$LOCALBASEDIR/$HASHFILENAME"

# If that's not the case either inform the user and exit
else
    echo "No supported file type was copied, exiting."
    notify-send -a "Copypasta" "No supported file type was copied"
    exit
fi
# scp the file into the remote server
scp "$LOCALBASEDIR/$HASHFILENAME" "$HOST:$REMOTEBASEDIR/"
# echo "$?"
    # Check if scp exited with status code 1. If that's the case, it failed so notify the user.
    if [ $? -eq 0 ]; then 
        echo "succeded"
        # Add the link into the clipboard
        echo "https://$URL/$HASHFILENAME" | xclip -selection clipboard
        notify-send "Copied into clipboard: https://$URL/$HASHFILENAME" -a "Copypasta"
    else
        echo "failed"
        notify-send "Failed to upload the paste" -a "Copypasta"
    fi