#!/bin/sh
# This script is used to set the correct permissions on the persistent volume 
# in order to allow the IRIS container to read and write to it without issues.

# Get the last directory of $PWD to replace docker_ in volume_name
source .env

set_permissions() {
    local volume_name="${VOLUME_PREFIX}_$1"
    local mount_point="/$1"
    docker run --rm -v "${volume_name}:${mount_point}" alpine sh -c \
        "chown -R 51773:51773 ${mount_point} && chmod -R u+rwX,g+rwX ${mount_point}"
}

# Set permissions for the persistent volume
set_permissions "databases_test"
set_permissions "journal_test"
set_permissions "journal2_test"
set_permissions "WIJ_test"  