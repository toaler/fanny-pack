#!/bin/bash

# Container name for easy reference
CONTAINER_NAME="firefox_sandbox"

# Image to use
IMAGE_NAME="lscr.io/linuxserver/firefox:latest"

# Ports to expose
PORTS="-p 3000:3000 -p 3001:3001"

# Shared memory size
SHM_SIZE="--shm-size=1gb"

start_container() {
    echo "Starting Firefox sandbox container..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        $PORTS \
        $SHM_SIZE \
        "$IMAGE_NAME"
    if [ $? -eq 0 ]; then
        echo "Firefox sandbox container started successfully."
    else
        echo "Failed to start Firefox sandbox container."
    fi
}

stop_container() {
    echo "Stopping Firefox sandbox container..."
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Firefox sandbox container stopped and removed successfully."
    else
        echo "Failed to stop or remove Firefox sandbox container."
    fi
}

status_container() {
    docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}"
}

case "$1" in
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    status)
        status_container
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac
