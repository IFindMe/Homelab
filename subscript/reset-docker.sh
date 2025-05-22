# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all user-defined networks (excluding 'bridge', 'host', 'none')
docker network rm $(docker network ls --filter type=custom -q)
