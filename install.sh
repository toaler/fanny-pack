#!/bin/zsh

echo "Setting up your environment for Zsh..."

# Variables
ZSHRC="$HOME/.zshrc"
REPO_PATH="$(pwd)"
CONFIG_DIR="$HOME/.config"
NVIM_DIR="$CONFIG_DIR/nvim"
REPO_URL="https://github.com/nvim-lua/kickstart.nvim.git"
BIN_DIR="$HOME/bin"
# Define the target symlink path
SYMLINK_PATH="$BIN_DIR/vim"
# Get the path to the nvim binary
NVIM_PATH=$(which nvim)

# Function to create symlinks
create_symlink() {
    local source=$1
    local target=$2
    if [ -e "$target" ]; then
        echo "Backing up existing $target to $target.bak"
        mv "$target" "$target.bak"
    fi
    echo "Creating symlink for $source -> $target"
    ln -sf "$source" "$target"
}

# Ensure the .config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating $CONFIG_DIR directory..."
    mkdir -p "$CONFIG_DIR"
else
    echo "$CONFIG_DIR directory already exists."
fi

# Link Zsh configuration files
create_symlink "$REPO_PATH/zsh/.zshrc" "$ZSHRC"
if [ -f "$REPO_PATH/zsh/aliases" ]; then
    echo "source $REPO_PATH/zsh/aliases" >> "$ZSHRC"
fi

# Ensure scripts are executable
if [ -d "$REPO_PATH/scripts" ]; then
    chmod +x "$REPO_PATH/scripts"/*.sh
    echo "Scripts in $REPO_PATH/scripts are now executable."
fi

# Copy scripts to $HOME/bin
if [ -d "$REPO_PATH/scripts" ]; then
    echo "Copying scripts to $HOME/bin..."

    if [ ! -d "$BIN_DIR" ]; then
        echo "Creating $BIN_DIR directory..."
        mkdir -p "$BIN_DIR"
    else
        echo "$BIN_DIR directory already exists."
    fi

    for script in "$REPO_PATH/scripts"/*; do
        if [ -f "$script" ]; then
            cp -f "$script" "$HOME/bin/"
        fi
    done
    echo "Scripts have been copied to $HOME/bin."
fi

# Run the setup_cronjobs.zsh script
if [ -f "$REPO_PATH/scripts/setup_cronjobs.zsh" ]; then
    echo "Executing setup_cronjobs.zsh..."
    chmod +x "$REPO_PATH/scripts/setup_cronjobs.zsh"
    "$REPO_PATH/scripts/setup_cronjobs.zsh"
    echo "Cron jobs have been set up."
else
    echo "setup_cronjobs.zsh script not found in $REPO_PATH/scripts!"
fi

# Source .zshrc to apply changes
if command -v zsh &> /dev/null; then
    echo "Sourcing $ZSHRC..."
    source "$ZSHRC"
    echo "Zsh configuration updated!"
else
    echo "Zsh not found! Please install Zsh and try again."
fi

# Check if the repository is already cloned
if [ ! -d "$NVIM_DIR" ]; then
    echo "Cloning repository into $NVIM_DIR..."
    git clone "$REPO_URL" "$NVIM_DIR"
else
    echo "Repository already cloned at $NVIM_DIR. Skipping clone."
fi

# Check if the symlink already exists and points to nvim
if [ -L "$SYMLINK_PATH" ] && [ "$(readlink "$SYMLINK_PATH")" == "$NVIM_PATH" ]; then
    echo "Symlink $SYMLINK_PATH already exists and points to nvim. No changes made."
else
    echo "Creating or updating symlink at $SYMLINK_PATH to point to $NVIM_PATH..."
    ln -sf "$NVIM_PATH" "$SYMLINK_PATH"
    echo "Symlink created/updated successfully."
fi
