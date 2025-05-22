#!/bin/bash

SRC_DIR=$(find / -type d -name "Homelab" 2>/dev/null | head -n 1)/config
DEST_DIR="/srv/docker"

FOLDERS=( "nginx")

for folder in "${FOLDERS[@]}"; do
    if [ -d "$SRC_DIR/$folder" ]; then
        cp -r "$SRC_DIR/$folder" "$DEST_DIR/"
        echo "Copied $folder to $DEST_DIR"
    else
        echo "Source folder $SRC_DIR/$folder does not exist."
    fi
done
