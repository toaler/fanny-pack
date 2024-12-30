# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# Define an array of paths to be added to PATH
paths_to_add=(
  "$HOME/bin"
  "$HOME/bin"
  "$HOME/.local/bin"
  "/usr/local/bin"
  "/opt/homebrew/opt/postgresql@16/bin"
  "/usr/X11/bin"
)

# Add each path to PATH if not already present
for new_path in "${paths_to_add[@]}"; do
  [[ ":$PATH:" != *":$new_path:"* ]] && PATH="$new_path:$PATH"
done

export PATH

fabric-youtube() {
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: fabric-youtube <YouTube_URL>"
        return 1
    fi

    # Ensure the config directory exists
    CONFIG_DIR="$HOME/.config/fabric/"
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Error: Configuration directory $CONFIG_DIR does not exist."
        return 1
    fi

    # Run the Docker container
    docker run -it --rm \
        -v "$CONFIG_DIR:/root/.config/fabric/" \
        fabric-instance:latest \
        --youtube="$1" --comments -sp analyze_comments
}


# General Navigation and File Management
alias ll='ls -alF'                    # Detailed file list with types
alias la='ls -A'                      # List all except . and ..
alias l='ls -CF'                      # Compact file list
alias ..='cd ..'                      # Go up one directory
alias ...='cd ../..'                  # Go up two directories
alias c='clear'                       # Clear terminal screen
alias mkdirp='mkdir -p'               # Create nested directories
alias rmr='rm -rf'                    # Force delete (use with caution)
alias cpv='cp -iv'                    # Copy with confirmation and verbose
alias mvv='mv -iv'                    # Move with confirmation and verbose
alias tree='find . | sed -e "s/[^-][^\\/]*\\//--/g;s/^/   /;s/--/|--/"' # Visualize directory tree
alias dls='ls | grep -i'              # Filter files by name

# System and Resource Management
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder' # Flush DNS cache
alias cls='sudo purge'                # Free inactive memory
alias meminfo='vm_stat'               # Display memory usage statistics
alias cpuinfo='top -l 1 | grep "CPU usage"' # Show current CPU usage
alias loadavg='uptime | awk -F "load averages: " "{print \$2}"' # Show load average
alias diskspace='df -h'               # Show disk usage in human-readable format
alias usage='du -sh *'                # Show sizes of files/folders in current directory
alias iostat='iostat -w 1'            # Show real-time CPU, disk I/O stats
alias freeports='sudo lsof -iTCP -sTCP:LISTEN -n -P' # Show open TCP ports
alias top10cpu='ps aux | sort -rk 3 | head -10' # Top 10 memory-intensive processes
alias top10mem='ps aux | sort -rk 4 | head -10' # Top 10 CPU-intensive processes

# Networking
alias myip='curl ifconfig.me'         # Show public IP address
alias localip='ipconfig getifaddr en0' # Show local IP address
alias pingtest='ping -c 5 google.com' # Quick network test
alias connections='netstat -anp tcp' # Show all network connections
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -' # Check internet speed
alias netinfo='ifconfig'              # Show network interfaces
alias hosts='sudo nano /etc/hosts'    # Edit hosts file
alias traceroute='traceroute google.com' # Trace network route to a server

# Docker Commands
alias dps='docker ps'                 # List running Docker containers
alias dpa='docker ps -a'              # List all Docker containers
alias di='docker images'              # List all Docker images
alias drm='docker rm $(docker ps -aq)' # Remove all stopped containers
alias drmi='docker rmi $(docker images -q)' # Remove all images
alias dlogs='docker logs'             # Show logs for a container
alias dexec='docker exec -it'         # Execute a command in a container
alias dstop='docker stop $(docker ps -q)' # Stop all running containers
alias dprune='docker system prune -af --volumes' # Clean unused Docker resources
alias dstart='docker start $(docker ps -aq)' # Start all containers

# Git Shortcuts
alias gst='git status'               # Show git status
alias gl='git pull'                  # Pull latest changes
alias gp='git push'                  # Push changes
alias ga='git add'                   # Add files to staging
alias gc='git commit -m'             # Commit with message
alias gco='git checkout'             # Checkout branch
alias gbr='git branch'               # List branches
alias gdiff='git diff'               # Show git diff
alias gamend='git commit --amend'    # Amend the last commit
alias greset='git reset --hard'      # Reset branch to last commit

# Miscellaneous Utilities
alias brewup='brew update && brew upgrade && brew cleanup' # Update Homebrew
alias dockrestart='killall Dock'      # Restart macOS Dock
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"' # Generate lowercase UUIDs
alias calc='bc -l'                    # Quick calculations
alias editrc='$EDITOR ~/.zshrc'       # Edit `.zshrc` file
alias sourcerc='source ~/.zshrc'      # Reload `.zshrc` file
alias pbcopy='xclip -selection clipboard' # Cross-platform clipboard copy
alias fabric='docker run -i --rm -v ~/.config/fabric/:/root/.config/fabric/ fabric-instance:latest'
alias fabric_aphorisms='fabric -sp create_aphorisms'
alias fab='docker run -it --rm -v ~/.config/fabric/:/root/.config/fabric/ fabric-instance:latest'
