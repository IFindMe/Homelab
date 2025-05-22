#!/bin/bash

# Service name for logging
SERVICE_NAME="portainer"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 3
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).3
VOLUME_BASE="/srv/docker/portainer"

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull portainer/portainer-ce:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -v $VOLUME_BASE/data:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce:latest

echo "$SERVICE_NAME service started successfully!"