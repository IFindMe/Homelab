#!/bin/bash

# Service name for logging
SERVICE_NAME="mariadb"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 8
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).8
VOLUME_BASE="/srv/docker/mariadb"

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull mariadb:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e MARIADB_USER_NEXTCLOUD=nextcloud \
  -e MARIADB_PASSWORD_NEXTCLOUD="my_(@Pass@:#./-)" \
  -e MARIADB_DATABASE_NEXTCLOUD=nextcloud_db \
  -e MARIADB_USER_WIKI=wikijs \
  -e MARIADB_PASSWORD_WIKI="my_(@Pass@:#./-)" \
  -e MARIADB_DATABASE_WIKI=wikijs_db \
  -e MARIADB_ROOT_PASSWORD="(@Pass@:#./-)" \
  -v $VOLUME_BASE/var/lib/mysql:/var/lib/mysql \
  mariadb:latest

echo "$SERVICE_NAME service started successfully!"