#!/bin/bash

# Service name for logging
SERVICE_NAME_DB="mariadb-nextcloud"

# Configuration variables
IP_ADDRESS_DB=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).44
VOLUME_BASE_DB="/srv/docker/mariadb/mariadb-nextcloud"

echo "Starting $SERVICE_NAME_DB service..."

docker pull mariadb:latest
docker stop $SERVICE_NAME_DB 2>/dev/null
docker rm $SERVICE_NAME_DB 2>/dev/null

docker run -d \
  --name $SERVICE_NAME_DB \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS_DB \
  -e MARIADB_USER=nextcloud \
  -e MARIADB_PASSWORD="my_(@Pass@:#./-)" \
  -e MARIADB_DATABASE=nextcloud_db \
  -e MARIADB_ROOT_PASSWORD="(@Pass@:#./-)" \
  -v $VOLUME_BASE_DB/var/lib/mysql:/var/lib/mysql \
  mariadb:latest

echo "$SERVICE_NAME_DB service started successfully!"


# Nextcloud service
SERVICE_NAME="nextcloud"
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).4
VOLUME_BASE="/srv/docker/nextcloud"

echo "Starting $SERVICE_NAME service..."

docker pull nextcloud:latest
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e MYSQL_HOST=$IP_ADDRESS_DB \
  -e MYSQL_DATABASE=nextcloud_db \
  -e MYSQL_USER=nextcloud \
  -e MYSQL_PASSWORD="my_(@Pass@:#./-)" \
  -v $VOLUME_BASE/var/www/html:/var/www/html \
  nextcloud:latest

echo "$SERVICE_NAME service started successfully!"
