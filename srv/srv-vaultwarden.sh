#!/bin/bash

# Service name for logging
SERVICE_NAME="vaultwarden"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 5
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).5
VOLUME_BASE="/srv/docker/vaultwarden"

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull vaultwarden/server:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e WEBSOCKET_ENABLED="true" \
  -v $VOLUME_BASE/data:/data \
  vaultwarden/server:latest

echo "$SERVICE_NAME service started successfully!"