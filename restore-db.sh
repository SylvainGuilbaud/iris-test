#!/bin/bash

BACKUP_FILE=${1:-"MiniTDNexLabs.bak"}
DATABASE_NAME=${2:-"miniTDNexLabs"}
NEW_DATABASE_NAME="${DATABASE_NAME}_restored"
SA_PASSWORD=${3:-"YourStrong!Passw0rd"}

echo "Copying backup file..."
docker cp "$BACKUP_FILE" test-mssql:/var/opt/mssql/

echo "Restoring database $DATABASE_NAME..."

# First, get the logical file names from the backup
echo "Discovering logical file names in backup..."
FILEINFO=$(docker exec test-mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P "$SA_PASSWORD" \
  -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/$(basename $BACKUP_FILE)';" \
  -h -1 -s "|" -W)

if [ $? -ne 0 ]; then
    echo "Failed to read backup file information"
    exit 1
fi

# Parse the logical file names (first column is logical name, third column is type)
DATA_FILE=$(echo "$FILEINFO" | grep "|D|" | head -1 | cut -d"|" -f1 | tr -d ' ')
LOG_FILE=$(echo "$FILEINFO" | grep "|L|" | head -1 | cut -d"|" -f1 | tr -d ' ')

echo "Found logical files:"
echo "   Data file: $DATA_FILE"
echo "   Log file:  $LOG_FILE"

if [ -z "$DATA_FILE" ] || [ -z "$LOG_FILE" ]; then
    echo "Could not determine logical file names"
    echo "Raw FILELISTONLY output:"
    echo "$FILEINFO"
    exit 1
fi

# Restore the database with correct logical file names
docker exec test-mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P "$SA_PASSWORD" \
  -Q "RESTORE DATABASE [$DATABASE_NAME] FROM DISK = '/var/opt/mssql/$(basename $BACKUP_FILE)' WITH MOVE '$DATA_FILE' TO '/var/opt/mssql/data/${NEW_DATABASE_NAME}.mdf', MOVE '$LOG_FILE' TO '/var/opt/mssql/data/${NEW_DATABASE_NAME}_log.ldf', REPLACE" \
  -t 300

echo "Restore completed!"