#!/bin/bash

# WARNING: DO NOT RECURSIVELY ADD COMMANDS TO THIS SCRIPT
# When adding new packages or tools:
# 1. Check if the package is already in the apt install list
# 2. Check if the package is already installed via another method
# 3. Add new packages only if they don't already exist in the script
# 4. Do not duplicate installation methods for the same package

# Exit on error
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Function to check if a snap is installed
snap_installed() {
    snap list "$1" 2>/dev/null | grep -q "^$1"
}

# Function to check if a flatpak is installed
flatpak_installed() {
    flatpak list | grep -q "$1"
}

# Function to clean up temporary files
cleanup() {
    rm -f wezterm-*.deb meslo.zip
}

# Register cleanup function to run on script exit
trap cleanup EXIT

# Remove problematic Codeium repository if it exists
if [ -f "/etc/apt/sources.list.d/codeium.list" ]; then
    echo "Removing problematic Codeium repository..."
    sudo rm /etc/apt/sources.list.d/codeium.list
fi

# --- Enable universe repository ---
echo "Enabling universe repository..."
echo "Adding component(s) 'universe' to all repositories." | sudo add-apt-repository universe -y

# Disable firewall
echo "Disabling firewall..."
sudo ufw disable

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install curl if not present
if ! command_exists curl; then
    echo "Installing curl..."
    sudo apt install -y curl
fi

# Install unzip if not present
if ! command_exists unzip; then
    echo "Installing unzip..."
    sudo apt install -y unzip
fi

# Install pip if not present
if ! command_exists pip3; then
    echo "Installing pip..."
    sudo apt install -y python3-pip
fi

# Install pipx if not present
if ! command -v pipx &> /dev/null; then
    echo "Installing pipx..."
    sudo apt install -y pipx
    pipx ensurepath
fi

# Install Flatpak if not present
if ! command_exists flatpak; then
    echo "Installing Flatpak..."
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Install WezTerm via Flatpak
if ! flatpak_installed org.wezfurlong.wezterm; then
    echo "Installing WezTerm via Flatpak..."
    flatpak install -y flathub org.wezfurlong.wezterm
    
    # Create desktop entry for WezTerm
    echo "Creating desktop entry for WezTerm..."
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/wezterm.desktop << 'EOL'
[Desktop Entry]
Name=WezTerm
Comment=A GPU-accelerated cross-platform terminal emulator
Exec=flatpak run org.wezfurlong.wezterm
Icon=wezterm
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
StartupWMClass=org.wezfurlong.wezterm
EOL
    
    # Download and set up WezTerm icon
    echo "Setting up WezTerm icon..."
    mkdir -p ~/.local/share/icons/hicolor/256x256/apps
    curl -L https://github.com/wez/wezterm/raw/main/assets/icon/terminal.png -o ~/.local/share/icons/hicolor/256x256/apps/wezterm.png
    
    # Create icon theme index
    echo "[Icon Theme]
Name=hicolor
Comment=Default icon theme
Directories=256x256/apps

[256x256/apps]
Size=256
Type=Fixed
Context=Applications" > ~/.local/share/icons/hicolor/index.theme
    
    # Update icon cache
    gtk-update-icon-cache ~/.local/share/icons/hicolor
    
    # Update desktop database
    update-desktop-database ~/.local/share/applications
fi

# Add WezTerm alias to .bashrc if not present
if ! grep -q "alias wezterm='flatpak run org.wezfurlong.wezterm'" ~/.bashrc; then
    echo "Adding WezTerm alias to .bashrc..."
    echo "alias wezterm='flatpak run org.wezfurlong.wezterm'" >> ~/.bashrc
fi

# Install packages via apt
echo "Installing apt packages..."
sudo apt install -y \
    aom-tools \
    bat \
    brotli \
    ca-certificates \
    libcairo2-dev \
    python3-certifi \
    libcjson-dev \
    dav1d \
    libeigen3-dev \
    eza \
    fd-find \
    ffmpeg \
    flac \
    fontconfig \
    freetype2-doc \
    fzf \
    gcc \
    gettext \
    ghostscript \
    giflib-tools \
    git-delta \
    libglib2.0-dev \
    libgmp-dev \
    gnutls-bin \
    libgraphite2-dev \
    libharfbuzz-dev \
    htop \
    icu-devtools \
    iftop \
    imagemagick \
    libjpeg-turbo8-dev \
    krb5-user \
    lame \
    leptonica-progs \
    libarchive-dev \
    libass-dev \
    libbluray-dev \
    libde265-dev \
    libdeflate-dev \
    libevent-dev \
    libgit2-dev \
    libheif-dev \
    libidn11-dev \
    libidn2-dev \
    libimagequant-dev \
    libmicrohttpd-dev \
    libmpc-dev \
    libnghttp2-dev \
    libogg-dev \
    libomp-dev \
    libpng-dev \
    libraw-dev \
    librist-dev \
    libsamplerate0-dev \
    libsm-dev \
    libsndfile1-dev \
    libsodium-dev \
    libsoxr-dev \
    libxcursor1 \
    libxrandr-dev \
    libxcb-cursor0 \
    libxcb1 \
    libxcb-util1 \
    libxcb-keysyms1 \
    libxcb-icccm4 \
    libxcb-render0 \
    libxcb-shape0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-shm0 \
    libxcb-dri2-0 \
    libxcb-dri3-0 \
    libxcb-present0 \
    libxcb-glx0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libssh-dev \
    libssh2-1-dev \
    libtasn1-6-dev \
    libtiff-dev \
    libtool \
    libunibreak-dev \
    libunistring-dev \
    libuv1-dev \
    libvidstab-dev \
    libvorbis-dev \
    libvpx-dev \
    libvterm-dev \
    libx11-dev \
    libxau-dev \
    libxcb1-dev \
    libxdmcp-dev \
    libxext-dev \
    libxmu-dev \
    libxrender-dev \
    libxt-dev \
    libyaml-dev \
    liblcms2-dev \
    llvm-16 \
    lz4 \
    m4 \
    maven \
    libmpfr-dev \
    mpg123 \
    libncurses-dev \
    neovim \
    nettle-dev \
    nload \
    nodejs \
    python3-numpy \
    libonig-dev \
    libopenblas-dev \
    openexr \
    openjdk-21-jdk \
    libopenjp2-7-dev \
    openssl \
    opus-tools \
    libp11-kit-dev \
    pandoc \
    libpango1.0-dev \
    libpcre3-dev \
    libpcre2-dev \
    python3-pil \
    libpixman-1-dev \
    protobuf-compiler \
    pybind11-dev \
    python3-matplotlib \
    python3-packaging \
    python3.12 \
    libqhull-dev \
    readline-common \
    rubberband-cli \
    libsdl2-dev \
    shared-mime-info \
    libsnappy-dev \
    speex \
    sqlite3 \
    srt-tools \
    sysstat \
    telnet \
    tesseract-ocr \
    thefuck \
    tmux \
    tree \
    wget \
    x264 \
    x265 \
    xclip \
    xdotool \
    xz-utils \
    libzmq3-dev \
    zoxide \
    zsh \
    zstd \
    xournalpp

# Install Google Chrome
echo "Installing Google Chrome..."
if ! command -v google-chrome &> /dev/null; then
    echo "Adding Google Chrome repository..."
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
else
    echo "Google Chrome is already installed"
fi

# Install snap packages
echo "Installing snap packages..."
if ! snap_installed sublime-text; then
    echo "Installing Sublime Text..."
    sudo snap install sublime-text --classic
fi

if ! snap_installed vlc; then
    echo "Installing VLC..."
    sudo snap install vlc
fi

if ! snap_installed zoom-client; then
    echo "Installing Zoom..."
    sudo snap install zoom-client
fi

if ! snap_installed helm; then
    echo "Installing Helm..."
    sudo snap install helm --classic
fi

if ! snap_installed kubectl; then
    echo "Installing kubectl..."
    sudo snap install kubectl --classic
fi

if ! snap_installed spotify; then
    echo "Installing Spotify..."
    sudo snap install spotify
fi

# Install jupyterlab using pipx
if ! command -v jupyter &> /dev/null; then
    echo "Installing jupyterlab..."
    pipx install jupyterlab
fi

# Install Ollama if not present
echo "Installing Ollama..."
if ! command_exists ollama; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Install Meslo Nerd Font if not present
echo "Installing Meslo Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
FONT_FILE="$FONT_DIR/MesloLGMNerdFont-Regular.ttf"

if [ ! -f "$FONT_FILE" ]; then
    mkdir -p "$FONT_DIR"
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip -o meslo.zip
    unzip -o meslo.zip -d "$FONT_DIR"
    fc-cache -f -v
fi

# Install Cursor
echo "Installing Cursor..."
if ! command -v cursor &> /dev/null; then
    # Create ~/.local/bin if it doesn't exist
    mkdir -p ~/.local/bin
    
    # Create a wrapper script to launch Cursor with --no-sandbox
    echo '#!/bin/bash
/usr/local/bin/cursor --no-sandbox "$@"' > ~/.local/bin/cursor
    chmod +x ~/.local/bin/cursor
    
    # Download and install Cursor icon
    mkdir -p ~/.local/share/icons
    wget -O ~/.local/share/icons/cursor.png https://cursor.sh/cursor.png
    
    # Create desktop entry with icon
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/cursor.desktop << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
Comment=AI-first code editor
Exec=/home/$USER/.local/bin/cursor %F
Icon=/home/$USER/.local/share/icons/cursor.png
Terminal=false
Categories=Development;TextEditor;IDE;
MimeType=text/plain;inode/directory;
StartupWMClass=Cursor
EOL
    
    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
else
    echo "Cursor is already installed"
fi

# Create desktop shortcut for Cursor AI
echo "Creating desktop shortcut for Cursor AI..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/cursor.desktop << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
Comment=AI-first code editor
Exec=cursor %F
Icon=/home/$USER/.local/share/icons/cursor.png
Terminal=false
Categories=Development;TextEditor;IDE;
StartupWMClass=Cursor
EOL

# Update desktop database
update-desktop-database ~/.local/share/applications

# Convert cursor icon...

# Install NordVPN CLI and GUI
echo "Installing NordVPN..."
if ! command -v nordvpn &> /dev/null; then
    # Install NordVPN CLI
    sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)
    
    # Install NordVPN GUI
    sudo apt install -y nordvpn-gui
    
    # Ensure nordvpn group exists and add user to it
    sudo groupadd nordvpn 2>/dev/null || true
    sudo usermod -aG nordvpn $USER
    
    echo "NordVPN installed successfully! Please log out and log back in for group changes to take effect."
else
    echo "NordVPN is already installed"
fi

# Install ImageMagick
echo "Installing ImageMagick..."
sudo apt install -y imagemagick

# Install performance tools
echo "Installing performance tools..."
sudo apt-get install -y \
    linux-tools-common \
    linux-tools-generic \
    linux-tools-$(uname -r) \
    bpfcc-tools \
    bpftrace \
    sysdig \
    strace \
    ltrace \
    perf-tools-unstable \
    systemtap

# Disable IPv6 system-wide
echo "Disabling IPv6 system-wide..."
sudo tee /etc/sysctl.d/99-disable-ipv6.conf > /dev/null <<EOL
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOL
sudo sysctl --system

# --- Network DNS Configuration ---
# NOTE: This section is commented out to prevent network disruption during installation
# If you need to configure DNS for 'toal-mesh' connection, run these commands manually after installation:
# sudo nmcli connection modify "toal-mesh" ipv4.dns "8.8.8.8 8.8.4.4"
# sudo nmcli connection modify "toal-mesh" ipv4.ignore-auto-dns yes
# sudo systemctl restart NetworkManager
#
# Set Google DNS for 'toal-mesh' Wi-Fi connection to avoid DNS/routing issues
# If you experience site-specific timeouts (e.g., Spotify), check your DNS settings and try a VPN
# To troubleshoot: try 'curl -v https://accounts.spotify.com/login' and verify DNS with 'resolvectl status'
# echo "Configuring Google DNS for 'toal-mesh' Wi-Fi connection..."
# sudo nmcli connection modify "toal-mesh" ipv4.dns "8.8.8.8 8.8.4.4"
# sudo nmcli connection modify "toal-mesh" ipv4.ignore-auto-dns yes
# sudo systemctl restart NetworkManager

# --- Linux Performance Optimizations ---
echo "Applying Linux performance optimizations..."

# Kernel Tuning
cat << EOL | sudo tee -a /etc/sysctl.conf
# Kernel Tuning
vm.swappiness=10
net.core.somaxconn=65535
fs.file-max=2097152
EOL
sudo sysctl --system

# I/O Scheduler for SSDs
echo "Setting I/O scheduler to none for NVMe drives..."
for drive in /sys/block/nvme*; do
    if [ -f "$drive/queue/scheduler" ]; then
        echo "none" | sudo tee "$drive/queue/scheduler"
    fi
done

# CPU Governor
sudo apt-get install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl restart cpufrequtils

# Swappiness
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl --system

# Filesystem Optimizations (for ext4)
sudo sed -i 's/defaults/defaults,noatime,discard/g' /etc/fstab
sudo mount -o remount /

# Network Tuning
cat << EOL | sudo tee -a /etc/sysctl.conf
# Network Tuning
net.ipv4.tcp_keepalive_time=60
net.ipv4.tcp_fin_timeout=30
EOL
sudo sysctl --system

# Graphics Drivers (NVIDIA example)
sudo apt-get install -y nvidia-driver-535

# Power Management
sudo apt-get install -y tlp tlp-rdw
sudo systemctl enable tlp
sudo systemctl start tlp

# --- Install Xournal++ ---
echo "Installing Xournal++..."
sudo apt-get install -y xournalpp

echo "Installation completed successfully!"
echo "To use WezTerm, either:"
echo "1. Run: flatpak run org.wezfurlong.wezterm"
echo "2. Or use the 'wezterm' alias (requires restarting your terminal or running: source ~/.bashrc)"

# Note: Some macOS-specific applications don't have direct Ubuntu equivalents:
# - alt-tab (use Alt+Tab built into Ubuntu)
# - bartender (use Ubuntu's built-in panel management)
# - breaktimer (use GNOME Break Timer)
# - cleanshot (use Flameshot or GNOME Screenshot)
# - clop (use GNOME Clipboard Manager)
# - discord (available via snap)
# - hiddenbar (use Ubuntu's built-in panel management)
# - itsycal (use GNOME Calendar)
# - kap (use SimpleScreenRecorder or OBS)
# - keka (use File Roller or PeaZip)
# - maccy (use CopyQ or GNOME Clipboard Manager)
# - meetingbar (use GNOME Calendar)
# - menubar-stats (use GNOME System Monitor)
# - obsidian (available via snap)
# - one-switch (use GNOME Extensions)
# - rectangle (use GNOME Extensions for window management)
# - soundsource (use PulseAudio Volume Control)
# - stats (use GNOME System Monitor)
# - wifi-explorer (use GNOME Network Manager)
# - xquartz (not needed on Linux)

# --- Check if OS changes have already been made ---
if [ -f /etc/sysctl.d/99-sysctl.conf ]; then
    echo "OS changes have already been applied. Skipping..."
else
    # Apply OS changes
    echo "Applying OS changes..."
    # (Your OS change commands here)
fi

# --- Install packages ---
echo "Installing packages..."
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    vim \
    htop \
    tmux \
    ripgrep \
    fd-find \
    bat \
    eza \
    zsh \
    fonts-powerline \
    acpi \
    libnotify-bin

# --- Install Obsidian ---
echo "Installing Obsidian..."
wget -O obsidian.deb https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.11/obsidian_1.5.11_amd64.deb
sudo dpkg -i obsidian.deb
sudo apt-get install -f -y  # Install any missing dependencies
rm obsidian.deb

# --- Install Calibre ---
echo "Installing Calibre..."
if ! command -v calibre &> /dev/null; then
    # Download and install Calibre
    wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
    echo "Calibre installed successfully!"
else
    echo "Calibre is already installed"
fi

# --- Install Google Chrome ---

# --- Setup Neovim Configuration ---
echo "Setting up Neovim configuration..."

# Create the nvim config directory if it doesn't exist
NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
    echo "Creating $NVIM_DIR directory..."
    mkdir -p "$NVIM_DIR"
fi

# Copy the Neovim configuration file
REPO_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$REPO_PATH/rc/nvim.lua" ]; then
    echo "Copying Neovim configuration to $NVIM_DIR/init.lua..."
    cp "$REPO_PATH/rc/nvim.lua" "$NVIM_DIR/init.lua"
    echo "Neovim configuration installed successfully."
else
    echo "Warning: $REPO_PATH/rc/nvim.lua not found! Neovim configuration not installed."
fi

echo ""
echo "=== IMPORTANT NOTES ==="
echo "1. Network DNS configuration was skipped to prevent installation disruption."
echo "   If you need to configure DNS for 'toal-mesh' connection, run these commands manually:"
echo "   sudo nmcli connection modify 'toal-mesh' ipv4.dns '8.8.8.8 8.8.4.4'"
echo "   sudo nmcli connection modify 'toal-mesh' ipv4.ignore-auto-dns yes"
echo "   sudo systemctl restart NetworkManager"
echo ""
echo "2. Some packages may have been installed already. The script is idempotent."
echo ""
echo "Installation script completed!" 