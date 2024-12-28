#!/bin/zsh

echo "Setting up your environment for Zsh..."

# Variables
ZSHRC="$HOME/.zshrc"
REPO_PATH="$(pwd)"

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
    mkdir -p "$HOME/bin"
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
