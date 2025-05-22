#!/bin/bash

# Service name for logging
SERVICE_NAME="nginx"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 7
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).7
VOLUME_BASE="/srv/docker/nginx"

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull nginx:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -p 80:80 \
  -p 443:443 \
  -v $VOLUME_BASE/etc/nginx/conf.d/:/etc/nginx/conf.d/ \
  nginx:latest

echo "$SERVICE_NAME service started successfully!"