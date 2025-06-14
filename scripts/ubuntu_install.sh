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

# Enable universe repository for extra packages if not already enabled
if ! grep -q "universe" /etc/apt/sources.list; then
    echo "Enabling universe repository..."
    sudo add-apt-repository universe -y
fi

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
    telnet \
    tesseract-ocr \
    thefuck \
    tmux \
    tree \
    wget \
    x264 \
    x265 \
    xclip \
    xz-utils \
    libzmq3-dev \
    zoxide \
    zsh \
    zstd

# Install snap packages one by one (with --classic where needed)
echo "Installing snap packages..."
for snap in sublime-text vlc zoom-client helm kubectl; do
    if ! snap_installed "$snap"; then
        echo "Installing $snap..."
        sudo snap install --classic "$snap"
    else
        echo "$snap is already installed"
    fi
done

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
Icon=cursor
Terminal=false
Categories=Development;TextEditor;IDE;
StartupWMClass=Cursor
EOL

# Convert cursor.webp to cursor.png and place in ~/.local/share/icons
echo "Converting cursor icon..."
mkdir -p ~/.local/share/icons
convert ~/Downloads/cursor.webp ~/.local/share/icons/cursor.png

# Update icon cache
gtk-update-icon-cache ~/.local/share/icons/hicolor

# Update desktop database
update-desktop-database ~/.local/share/applications

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
sudo apt install -y \
    linux-tools-common \
    linux-tools-generic \
    linux-tools-$(uname -r) \
    bpfcc-tools \
    bpftrace \
    sysdig \
    strace \
    ltrace \
    perf-tools-unstable \
    systemtap \
    # CPU monitoring
    sysstat \
    mpstat \
    iotop \
    # Memory monitoring
    memstat \
    numastat \
    # Network monitoring
    iperf3 \
    nethogs \
    iftop \
    nload \
    # Disk monitoring
    iotop \
    iostat \
    smartmontools \
    hdparm \
    # System monitoring
    atop \
    dstat \
    glances \
    # Process monitoring
    pidstat \
    procps

# Install flamegraphs via pip
echo "Installing flamegraphs..."
pip3 install flamegraphs

# Download IBKR Trader Workstation installer
echo "Downloading IBKR Trader Workstation installer..."
mkdir -p ~/Downloads
wget -O ~/Downloads/tws-latest-linux-x64.sh https://download2.interactivebrokers.com/installers/tws/latest/tws-latest-linux-x64.sh

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