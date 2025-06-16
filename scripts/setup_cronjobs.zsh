#!/bin/zsh

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Check if crontab exists
if ! command -v crontab &> /dev/null; then
    echo "crontab not found. Please ensure cron is installed and enabled on your system."
    exit 1
fi

# Create a directory for logs if it doesn't exist
LOG_DIR=~/Documents/Logs
mkdir -p "$LOG_DIR"

# Create a temporary crontab file
CRON_TEMP=$(mktemp)

# Add existing crontab entries to the temporary file
crontab -l > "$CRON_TEMP" 2>/dev/null

# Common cron jobs for both OS
echo "0 0 * * * /usr/bin/find ~/Downloads -type f -mtime +30 -exec rm {} \\;" >> "$CRON_TEMP" # Clean Downloads folder
echo "*/10 * * * * /usr/bin/env df -h > $LOG_DIR/disk_usage_log.txt" >> "$CRON_TEMP" # Log disk usage every 10 minutes

# OS-specific cron jobs
if [[ "$OS" == "macos" ]]; then
    echo "0 6 * * * /usr/bin/osascript -e 'display notification \"Time to wake up!\" with title \"Good Morning\"'" >> "$CRON_TEMP" # Morning reminder
    echo "0 * * * * /usr/bin/top -l 1 > $LOG_DIR/system_stats.txt" >> "$CRON_TEMP" # Hourly system stats
    echo "0 22 * * 0 /usr/bin/env osascript -e 'display notification \"Weekly backup completed!\" with title \"Backup Status\"'" >> "$CRON_TEMP" # Weekly backup reminder
    echo "0 3 * * 1-5 /usr/local/bin/backup.sh" >> "$CRON_TEMP" # Weekday backup script
    echo "*/15 * * * * /usr/bin/pmset -g log | grep -i battery > $LOG_DIR/battery_log.txt" >> "$CRON_TEMP" # Battery status logging
    echo "0 12 * * 1 /usr/local/bin/cleanup_logs.sh" >> "$CRON_TEMP" # Weekly log cleanup
    echo "0 4 1 * * /usr/local/bin/update_homebrew.sh" >> "$CRON_TEMP" # Monthly Homebrew updates
elif [[ "$OS" == "linux" ]]; then
    echo "0 6 * * * /usr/bin/notify-send \"Time to wake up!\" \"Good Morning\"" >> "$CRON_TEMP" # Morning reminder
    echo "0 * * * * /usr/bin/top -b -n 1 > $LOG_DIR/system_stats.txt" >> "$CRON_TEMP" # Hourly system stats
    echo "0 22 * * 0 /usr/bin/notify-send \"Weekly backup completed!\" \"Backup Status\"" >> "$CRON_TEMP" # Weekly backup reminder
    echo "0 3 * * 1-5 /usr/local/bin/backup.sh" >> "$CRON_TEMP" # Weekday backup script
    echo "*/15 * * * * /usr/bin/acpi -b > $LOG_DIR/battery_log.txt" >> "$CRON_TEMP" # Battery status logging
    echo "0 12 * * 1 /usr/local/bin/cleanup_logs.sh" >> "$CRON_TEMP" # Weekly log cleanup
    echo "0 4 1 * * /usr/local/bin/update_packages.sh" >> "$CRON_TEMP" # Monthly package updates
fi

# Install the new crontab
crontab "$CRON_TEMP"

# Clean up
rm "$CRON_TEMP"

echo "Cron jobs installed successfully! Logs are stored in $LOG_DIR."
