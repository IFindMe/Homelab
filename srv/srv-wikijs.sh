#!/bin/bash

# Service name for logging
SERVICE_NAME_DB="mariadb"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 99
IP_ADDRESS_DB=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).99
VOLUME_BASE_DB="/srv/docker/mariadb/mariadb-wikijs"

echo "Starting $SERVICE_NAME_DB service..."

# Pull the latest image
docker pull mariadb:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME_DB 2>/dev/null
docker rm $SERVICE_NAME_DB 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME_DB \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS_DB \
  -e MARIADB_USER=wikijs \
  -e MARIADB_PASSWORD="(@Pass@:#./-)" \
  -e MARIADB_DATABASE=wikijs \
  -v $VOLUME_BASE_DB/var/lib/mysql:/var/lib/mysql \
  mariadb:latest

echo "$SERVICE_NAME_DB service started successfully!"



# Service name for logging
SERVICE_NAME="wikijs"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 9
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).9
VOLUME_BASE="/srv/docker/wikijs"

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
  -e DB_HOST=$IP_ADDRESS_DB \
  -e DB_PORT=3306 \
  -e DB_USER=wikijs \
  -e DB_PASS="(@Pass@:#./-)" \
  -e DB_NAME=wikijs \
  -v $VOLUME_BASE/var/lib/wiki:/var/lib/wiki \
  requarks/wiki:latest

echo "$SERVICE_NAME service started successfully!"
