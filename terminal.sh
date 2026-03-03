#!/bin/bash

TARGET=${1:-test}

case "$TARGET" in
    test)
        CONTAINER="iris-test"
        ;;
    prod1)
        CONTAINER="iris-prod-1"
        ;;
    prod2)
        CONTAINER="iris-prod-2"
        ;;
    *)
        echo "Usage: $0 [test|prod1|prod2]"
        exit 1
        ;;
esac

docker exec -it "$CONTAINER" iris session iris -U IRISAPP