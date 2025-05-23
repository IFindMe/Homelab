#!/bin/bash

SERVICE_NAME="affine"
NETWORK="homelab-network"

# Extract subnet base for IP assignment
# Get the subnet from homelab-network and set last octet to 10
SUBNET_BASE=$(docker network inspect $NETWORK | jq -r '.[0].IPAM.Config[0].Subnet' | cut -d. -f1-3).10

# Assign IPs (adjust last octet as needed)
AFFINE_IP="${SUBNET_BASE}.10"
REDIS_IP="${SUBNET_BASE}.11"
POSTGRES_IP="${SUBNET_BASE}.12"
MIGRATION_IP="${SUBNET_BASE}.13"

UPLOAD_LOCATION="/path/to/upload"
CONFIG_LOCATION="/path/to/config"
DB_DATA_LOCATION="/path/to/dbdata"

DB_USERNAME="your_db_user"
DB_PASSWORD="your_db_pass"
DB_DATABASE="affine"
AFFINE_REVISION="stable"
PORT="3010"

echo "Starting $SERVICE_NAME stack..."

# Pull images
docker pull ghcr.io/toeverything/affine-graphql:${AFFINE_REVISION}
docker pull redis:latest
docker pull postgres:16

# Stop and remove containers if exist
docker stop affine_server affine_redis affine_postgres affine_migration_job 2>/dev/null
docker rm affine_server affine_redis affine_postgres affine_migration_job 2>/dev/null

# Start Postgres container
docker run -d --name affine_postgres \
  --restart unless-stopped \
  --network $NETWORK --ip $POSTGRES_IP \
  -e POSTGRES_USER=$DB_USERNAME \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  -e POSTGRES_DB=$DB_DATABASE \
  -e POSTGRES_INITDB_ARGS='--data-checksums' \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  -v ${DB_DATA_LOCATION}:/var/lib/postgresql/data \
  postgres:16

# Start Redis container
docker run -d --name affine_redis \
  --restart unless-stopped \
  --network $NETWORK --ip $REDIS_IP \
  redis:latest

# Run migration job (wait for DB and Redis is your problem)
docker run --rm --name affine_migration_job \
  --network $NETWORK --ip $MIGRATION_IP \
  -v ${UPLOAD_LOCATION}:/root/.affine/storage \
  -v ${CONFIG_LOCATION}:/root/.affine/config \
  -e REDIS_SERVER_HOST=affine_redis \
  -e DATABASE_URL="postgresql://${DB_USERNAME}:${DB_PASSWORD}@${POSTGRES_IP}:5432/${DB_DATABASE}" \
  ghcr.io/toeverything/affine-graphql:${AFFINE_REVISION} \
  sh -c 'node ./scripts/self-host-predeploy.js'

# Start affine server
docker run -d --name affine_server \
  --restart unless-stopped \
  --network $NETWORK --ip $AFFINE_IP \
  -p ${PORT}:3010 \
  -v ${UPLOAD_LOCATION}:/root/.affine/storage \
  -v ${CONFIG_LOCATION}:/root/.affine/config \
  -e REDIS_SERVER_HOST=affine_redis \
  -e DATABASE_URL="postgresql://${DB_USERNAME}:${DB_PASSWORD}@${POSTGRES_IP}:5432/${DB_DATABASE}" \
  ghcr.io/toeverything/affine-graphql:${AFFINE_REVISION}

echo "$SERVICE_NAME stack started."
