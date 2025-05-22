#!/bin/bash

# Set Pi-hole container name
echo "[*] Available Docker containers:"
docker ps --format "table {{.Names}}\t{{.Image}}"
read -p "[?] Enter the Pi-hole container name: " PIHOLE_CONTAINER

# Set Pi-hole admin password inside container
read -s -p "[?] Enter new Pi-hole admin password: " PIHOLE_PASS
echo
echo "[*] Setting Pi-hole admin password..."
docker exec -i "$PIHOLE_CONTAINER" pihole setpassword "$PIHOLE_PASS"

