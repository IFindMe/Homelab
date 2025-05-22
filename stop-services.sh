#!/bin/bash

# Stop and remove all running containers

containers=$(docker ps -q)
if [ -n "$containers" ]; then
    docker stop $containers
    docker rm $containers
else
    echo "No running containers to stop or remove."
fi

# reset docker with docker reset script
reset_script=$(find / -type f -name "reset-docker.sh" 2>/dev/null | head -n 1)

if [ -z "$reset_script" ]; then
    echo "reset-docker.sh not found! Exiting."
    exit 1
fi
chmod +x "$reset_script"
bash "$reset_script"