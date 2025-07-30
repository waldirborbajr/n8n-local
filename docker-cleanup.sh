#!/bin/bash

# Function to check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed."
        exit 1
    fi
    if ! docker info &> /dev/null; then
        echo "Error: Docker daemon is not running."
        exit 1
    fi
}

# Function to handle errors (logs error but continues execution)
handle_error() {
    echo "Warning: Error occurred during $1: $2"
}

# Check Docker installation and daemon
check_docker

# Remove all Docker services
echo "Removing all Docker services..."
docker service rm $(docker service ls -q) 2>/dev/null || handle_error "removing services" "Failed to remove some services."

# Leave Docker Swarm
echo "Leaving Docker Swarm..."
docker swarm leave --force 2>/dev/null || handle_error "leaving swarm" "Failed to leave Docker Swarm."

# Stop all running containers
echo "Stopping all running containers..."
docker stop $(docker ps -q) 2>/dev/null || handle_error "stopping containers" "Failed to stop some containers."

# Remove all containers
echo "Removing all containers..."
docker rm -f $(docker ps -a -q) 2>/dev/null || handle_error "removing containers" "Failed to remove some containers."

# Remove all images
echo "Removing all images..."
docker rmi -f $(docker images -q) 2>/dev/null || handle_error "removing images" "Failed to remove some images."

# Remove all volumes
echo "Removing all volumes..."
docker volume rm -f $(docker volume ls -q) 2>/dev/null || handle_error "removing volumes" "Failed to remove some volumes."

# Remove all networks (except default ones)
echo "Removing all custom networks..."
docker network rm $(docker network ls -q | grep -v "bridge\|host\|none") 2>/dev/null || handle_error "removing networks" "Failed to remove some networks."

# Prune system to remove any remaining unused data
echo "Pruning Docker system..."
docker system prune -a -f --volumes 2>/dev/null || handle_error "system prune" "Failed to prune Docker system."

# Remove EasyPanel configuration
echo "Removing EasyPanel configuration..."
sudo rm -rf /etc/easypanel 2>/dev/null || handle_error "removing easypanel" "Failed to remove EasyPanel configuration."

echo "Docker cleanup completed successfully."

