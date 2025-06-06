#!/bin/bash

# ====== Configuration ======
SERVICE_NAME="synapse"
IP_ADDRESS=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).6
IMAGE_NAME="matrixdotorg/synapse:latest"
VOLUME_BASE="/srv/docker/$SERVICE_NAME"
SERVER_NAME="matrix1.serdem.org"
RESTART_POLICY="always"


# ====== Start ======
echo "Starting $SERVICE_NAME service..."

# Pull latest image
docker pull $IMAGE_NAME

# Stop and remove existing container
docker stop $SERVICE_NAME 2>/dev/null
docker rm $SERVICE_NAME 2>/dev/null

#generate config:
docker run -it --rm \
  -v $VOLUME_BASE/data:/data \
  -e SYNAPSE_SERVER_NAME=matrix.home.net \
  -e SYNAPSE_REPORT_STATS=yes \
  $IMAGE_NAME


# Run the container
docker run -d \
  --name $SERVICE_NAME \
  --restart $RESTART_POLICY \
  -v $VOLUME_BASE/data:/data \
  -e SYNAPSE_SERVER_NAME=$SERVER_NAME \
  -e SYNAPSE_REPORT_STATS=yes \
  --network homelab-network \
  --ip $IP_ADDRESS \
  $IMAGE_NAME

echo "$SERVICE_NAME service started successfully!"
