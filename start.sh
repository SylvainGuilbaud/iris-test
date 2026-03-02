#!/bin/bash
# Start script for iris-training
# This script is used to start the IRIS container and ensure that the correct permissions are set on the persistent volumes.
source .env
# Set permissions on the persistent volumes
echo "Setting permissions on persistent volumes..."
create_volumes_with_permissions.sh
# Start the containers
echo "Starting the containers..."
docker-compose -p "${VOLUME_PREFIX}" up -d
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start the containers."
    exit 1
else
    echo "Containers started successfully."    
fi