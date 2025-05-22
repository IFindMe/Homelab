#!/bin/bash

# Service name for logging
SERVICE_NAME="nextcloud"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 4
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).4
VOLUME_BASE="/srv/docker/nextcloud"
DB_HOST=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).8

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull nextcloud:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e MYSQL_HOST=$DB_HOST \
  -e MYSQL_DATABASE=nextcloud_db \
  -e MYSQL_USER=nextcloud \
  -e MYSQL_PASSWORD="my_(@Pass@:#./-)" \
  -v $VOLUME_BASE/var/www/html:/var/www/html \
  nextcloud:latest

echo "$SERVICE_NAME service started successfully!"