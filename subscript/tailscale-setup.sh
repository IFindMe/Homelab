#!/bin/bash

# homelab-network subnet 
SUBNET=$(docker network inspect homelab-network | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).0/24

# Update and install Tailscale
sudo apt-get update
curl -fsSL https://tailscale.com/install.sh | sh

# Enable and start Tailscale service
sudo tailscaled >/dev/null 2>&1 &

# Authenticate Tailscale (manual step)
sudo tailscale up


echo "Now setup Nameservers Tailscale DNS panel:"
echo "https://login.tailscale.com/admin/dns"