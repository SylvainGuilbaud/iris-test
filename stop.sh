#!/bin/bash
# Stop script 
# This script is used to stop the containers and ensure that all related containers are stopped properly.
source .env
echo "Stopping the containers..."
docker-compose -p "${VOLUME_PREFIX}" down
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop the containers."
    exit 1
else
    echo "Containers stopped successfully."    
fi