#!/bin/bash

# Script to create a Docker network named 'homelab-network'

echo "=== Creating Functional Docker Network ==="
read -p "Enter network name [homelab-network]: " NETWORK_NAME
NETWORK_NAME=${NETWORK_NAME:-homelab-network}

read -p "Enter subnet [172.25.0.0/24]: " SUBNET
SUBNET=${SUBNET:-172.25.0.0/24}


docker network create \
  --driver=bridge \
  --subnet="$SUBNET" \
  --opt com.docker.network.bridge.name=br-homelab \
  "$NETWORK_NAME"

echo "Docker network '$NETWORK_NAME' created with subnet $SUBNET and gateway $GATEWAY."
