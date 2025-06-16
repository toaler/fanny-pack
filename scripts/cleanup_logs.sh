#!/bin/bash

# Define log directory
LOG_DIR=~/Documents/Logs

# Remove log files older than 30 days
find "$LOG_DIR" -type f -name "*.txt" -mtime +30 -delete

echo "Log cleanup completed" 