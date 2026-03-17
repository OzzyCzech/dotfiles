SOURCE=${0%/*}

# Force xterm-256color terminal for all terminals
export TERM=xterm-256color

# Paths
source "$SOURCE/paths.zsh"

# Aliases
source "$SOURCE/aliases.zsh"

source "$SOURCE/eza.zsh"
source "$SOURCE/functions.zsh"
source "$SOURCE/autoenv.zsh"
source "$SOURCE/docker.zsh"
source "$SOURCE/ai.zsh"

# Libraries
source "$SOURCE/history.zsh"
source "$SOURCE/prompt.zsh"

# Load extra (if available)
[[ -f "$SOURCE/extra.zsh" ]] && source "$SOURCE/extra.zsh"