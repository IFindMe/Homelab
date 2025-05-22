#!/bin/bash

# Service name for logging
SERVICE_NAME="gitlab"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 6
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).6
VOLUME_BASE="/srv/docker/gitlab"

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull gitlab/gitlab-ee:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --hostname gitlab.home.net \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.home.net'" \
  -v $VOLUME_BASE/etc/gitlab:/etc/gitlab \
  -v $VOLUME_BASE/var/log/gitlab:/var/log/gitlab \
  -v $VOLUME_BASE/var/opt/gitlab:/var/opt/gitlab \
  gitlab/gitlab-ee:latest

echo "$SERVICE_NAME service started successfully!"