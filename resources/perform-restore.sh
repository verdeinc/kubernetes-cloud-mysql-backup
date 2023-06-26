#!/bin/sh

# Set the restore_failed variable to false. This will change if any of the subsequent restore operations fail.
restore_failed=false

# Check if the backup file name is provided
if [ -z "$BACKUP_FILE_NAME" ]; then
    echo "Please provide the backup file name to restore in BACKUP_FILE_NAME environment variable."
    exit 1
fi

# Download the backup from S3
if awsoutput=$(aws $ENDPOINT s3 cp s3://$AWS_BUCKET_NAME$AWS_BUCKET_BACKUP_PATH/$BACKUP_FILE_NAME /tmp/backup.sql 2>&1); then
    echo -e "Database backup successfully downloaded for restoration at $(date +'%d-%m-%Y %H:%M:%S')."
else
    echo -e "Failed to download database backup at $(date +'%d-%m-%Y %H:%M:%S'). Error: $awsoutput"
    restore_failed=true
fi

# If the restore_failed flag is still false, perform the restore operation
if [ "$restore_failed" = false ]; then
    if mysqloutput=$(mysql -u $TARGET_DATABASE_USER -h $TARGET_DATABASE_HOST -p$TARGET_DATABASE_PASSWORD -P $TARGET_DATABASE_PORT < /tmp/backup.sql 2>&1); then
        echo -e "Database restored successfully from $BACKUP_FILE_NAME at $(date +'%d-%m-%Y %H:%M:%S')."
    else
        echo -e "Database restore FAILED at $(date +'%d-%m-%Y %H:%M:%S'). Error: $mysqloutput"
        restore_failed=true
    fi
fi

# Remove the downloaded backup file
rm /tmp/backup.sql

# If the restore operation failed, exit with status code 1. Otherwise, exit with status code 0.
if [ "$restore_failed" = true ]; then
    exit 1
else
    exit 0
fi
