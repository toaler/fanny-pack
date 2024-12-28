#!/bin/zsh

echo "Starting system cleanup..."

# Clear system caches
clear_system_caches() {
    echo "Clearing system caches..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    echo "System caches cleared."
}

# Purge inactive memory
purge_memory() {
    echo "Purging inactive memory..."
    sudo purge
    echo "Inactive memory purged."
}

# Cleanup user caches
cleanup_user_caches() {
    echo "Cleaning up user caches..."
    CACHE_DIR="$HOME/Library/Caches"
    if [ -d "$CACHE_DIR" ]; then
        rm -rf "$CACHE_DIR"/*
        echo "User caches cleared."
    else
        echo "No user cache directory found."
    fi
}

# Empty the Trash
empty_trash() {
    echo "Emptying Trash..."
    TRASH_DIR="$HOME/.Trash"
    if [ -d "$TRASH_DIR" ]; then
        rm -rf "$TRASH_DIR"/*
        echo "Trash emptied."
    else
        echo "No Trash directory found."
    fi
}

# Remove old logs
cleanup_logs() {
    echo "Cleaning up old logs..."
    LOG_DIRS=(
        "$HOME/Library/Logs"
        "/Library/Logs"
        "/var/log"
    )
    for dir in "${LOG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f -name "*.log" -mtime +7 -exec rm -f {} \;
            echo "Old logs cleared in $dir."
        fi
    done
}

# Remove old downloads
cleanup_downloads() {
    echo "Cleaning up old files in Downloads..."
    DOWNLOADS_DIR="$HOME/Downloads"
    if [ -d "$DOWNLOADS_DIR" ]; then
        find "$DOWNLOADS_DIR" -type f -mtime +30 -exec rm -f {} \;
        echo "Old downloads removed."
    else
        echo "No Downloads directory found."
    fi
}

# Cleanup Homebrew cache
cleanup_homebrew_cache() {
    if command -v brew &> /dev/null; then
        echo "Cleaning up Homebrew cache..."
        brew cleanup -s
        echo "Homebrew cache cleaned."
    else
        echo "Homebrew not found. Skipping cleanup."
    fi
}

# Execute cleanup tasks
clear_system_caches
purge_memory
cleanup_user_caches
empty_trash
cleanup_logs
cleanup_downloads
cleanup_homebrew_cache

echo "System cleanup complete!"
