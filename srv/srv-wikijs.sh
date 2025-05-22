#!/bin/bash

# Service name for logging
SERVICE_NAME="wikijs"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 9
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).9
VOLUME_BASE="/srv/docker/wikijs"
DB_HOST=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).8

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull requarks/wiki:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e DB_TYPE=mariadb \
  -e DB_HOST=$DB_HOST \
  -e DB_PORT=3306 \
  -e DB_USER=wikijs \
  -e DB_PASS="(@Pass@:#./-)" \
  -e DB_NAME=wikijs \
  -v $VOLUME_BASE/var/lib/wiki:/var/lib/wiki \
  requarks/wiki:latest

echo "$SERVICE_NAME service started successfully!"