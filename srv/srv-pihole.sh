#!/bin/bash

# Service name for logging
SERVICE_NAME="pihole"

# Configuration variables
# Get the subnet from homelab-network and set last octet to 2
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).2
VOLUME_BASE="/srv/docker/pihole"

echo "Starting $SERVICE_NAME service..."

# Pull the latest image
docker pull pihole/pihole:latest

# Stop and remove existing container if it exists
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart unless-stopped \
  --network homelab-network \
  --ip $IP_ADDRESS \
  -e TZ="UTC" \
  -e DNSMASQ_LISTENING=all \
  --cap-add=NET_ADMIN \
  -p 53:53/tcp \
  -p 53:53/udp \
  -p 8080:80 \
  -p 4430:443 \
  -v $VOLUME_BASE/etc/pihole:/etc/pihole \
  -v $VOLUME_BASE/etc/dnsmasq.d:/etc/dnsmasq.d \
  pihole/pihole:latest
#

echo "$SERVICE_NAME service started successfully!"