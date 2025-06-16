#!/bin/bash

# Update package lists
sudo apt-get update

# Upgrade packages
sudo apt-get upgrade -y

# Clean up
sudo apt-get autoremove -y
sudo apt-get clean

echo "System packages updated" 