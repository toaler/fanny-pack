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
# Define TMUX-related variables
TMUX_SOURCE_DIR="./tmux"
TMUX_SOURCE_FILE="$TMUX_SOURCE_DIR/tmux.conf"
TMUX_TARGET_FILE="$HOME/.tmux.conf"
TMUX_TARGET_DIR="$HOME/.tmux/plugins/tpm"

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

test_truecolor() {
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm\033[38;2;%d;%d;%dm%s\033[0m", r,g,b, r,g,b, substr(s,colnum%8+1,1);
        }
        printf "\n";
    }'
}

copy_rc_files_to_home() {
  # Directory containing the files to process
  rc_dir="./rc"

  # Check if the directory exists
  if [[ ! -d "$rc_dir" ]]; then
    echo "Error: Directory '$rc_dir' does not exist."
    return 1
  fi

  # Loop through all files in the rc directory
  for file in "$rc_dir"/*; do
    # Check if it's a file (not a directory or symlink)
    if [[ -f "$file" ]]; then
      # Get the base name of the file (no directory path)
      base_name=$(basename "$file")

      # Copy the file to the home directory, prefixing with a dot and preserving the timestamp
      cp -p "$file" "$HOME/.$base_name"
    fi
  done

  echo "All files from '$rc_dir' have been copied to '$HOME' with a dot prefix and timestamps preserved."
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
if [[ -L "$SYMLINK_PATH" && "$(readlink "$SYMLINK_PATH")" == "$NVIM_PATH" ]]; then
    echo "Symlink $SYMLINK_PATH already exists and points to nvim. No changes made."
else
    echo "Creating or updating symlink at $SYMLINK_PATH to point to $NVIM_PATH..."
    ln -sf "$NVIM_PATH" "$SYMLINK_PATH"
    echo "Symlink created/updated successfully."
fi

# Check if the directory already exists
if [ -d "$TMUX_TARGET_DIR" ]; then
  echo "TPM is already installed in $TMUX_TARGET_DIR."
else
  echo "Cloning TPM repository into $TMUX_TARGET_DIR..."
  git clone https://github.com/tmux-plugins/tpm "$TMUX_TARGET_DIR"
  if [ $? -eq 0 ]; then
    echo "TPM successfully installed."
  else
    echo "Failed to clone TPM repository." >&2
    exit 1
  fi
fi

# Check if the source file exists
if [[ ! -f "$TMUX_SOURCE_FILE" ]]; then
    echo "Error: Source file $TMUX_SOURCE_FILE does not exist."
    exit 1
fi

# Compare and copy the file if necessary
if [[ -f "$TMUX_TARGET_FILE" ]]; then
    if cmp -s "$TMUX_SOURCE_FILE" "$TMUX_TARGET_FILE"; then
        echo "The file $TMUX_TARGET_FILE is already up-to-date. No changes made."
    else
        echo "Updating $TMUX_TARGET_FILE with the latest version from $TMUX_SOURCE_FILE..."
        cp "$TMUX_SOURCE_FILE" "$TMUX_TARGET_FILE"
        echo "$TMUX_TARGET_FILE updated successfully."
    fi
else
    echo "Copying $TMUX_SOURCE_FILE to $TMUX_TARGET_FILE..."
    cp "$TMUX_SOURCE_FILE" "$TMUX_TARGET_FILE"
    echo "$TMUX_TARGET_FILE created successfully."
fi

# Check if tmux-256color is already installed
if infocmp tmux-256color >/dev/null 2>&1; then
  echo "tmux-256color is already installed."
else
  echo "Installing tmux-256color terminfo..."
  if [ -f "tmux/tmux-256color.src" ]; then
    tic -x tmux/tmux-256color.src
    if [ $? -eq 0 ]; then
      echo "tmux-256color installed successfully."
    else
      echo "Failed to install tmux-256color." >&2
      exit 1
    fi
  else
    echo "tmux-256color.src file not found in tmux directory." >&2
    exit 1
  fi
fi

# Setup fzf

# Define the target file and URL
TARGET_FILE=~/bin/fzf-git.sh
URL=https://raw.githubusercontent.com/junegunn/fzf-git.sh/master/fzf-git.sh

# Download the file using curl with error handling
if curl -fLo "$TARGET_FILE" --create-dirs "$URL"; then
    echo "Downloaded fzf-git.sh successfully."
else
    echo "Failed to download fzf-git.sh." >&2
    exit 1
fi

# Check if the file is readable and contains no errors
if [ -r "$TARGET_FILE" ] && grep -q 'fzf' "$TARGET_FILE"; then
    echo "Sourcing fzf-git.sh..."
    . "$TARGET_FILE"
else
    echo "Error: fzf-git.sh is not valid or readable." >&2
    exit 1
fi


copy_rc_files_to_home

. ~/.zshrc
