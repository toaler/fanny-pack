#!/bin/bash

# Create backup directory if it doesn't exist
BACKUP_DIR=~/Documents/Backups
mkdir -p "$BACKUP_DIR"

# Get current date for backup name
DATE=$(date +%Y-%m-%d)

# Create backup of important directories
tar -czf "$BACKUP_DIR/home_backup_$DATE.tar.gz" \
    ~/Documents \
    ~/Downloads \
    ~/Pictures \
    ~/Videos

# Keep only the last 5 backups
ls -t "$BACKUP_DIR"/home_backup_*.tar.gz | tail -n +6 | xargs -r rm

echo "Backup completed: $BACKUP_DIR/home_backup_$DATE.tar.gz" 