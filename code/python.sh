#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi
PACKAGE_NAME=$1

if python3 -m pip show $PACKAGE_NAME > /dev/null 2>&1; then
    echo "Package $PACKAGE_NAME is already installed, updating..."
    python3 -m pip install --upgrade --target /usr/irissys/mgr/python $PACKAGE_NAME
    exit 0
fi

python3 -m pip install --target /usr/irissys/mgr/python $PACKAGE_NAME