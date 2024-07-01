SOURCE=${0%/*}

# Paths
source "$SOURCE/paths.zsh"

# Aliases
source "$SOURCE/aliases.zsh"

source "$SOURCE/eza.zsh"
source "$SOURCE/functions.zsh"
source "$SOURCE/password.zsh"
source "$SOURCE/encode64.zsh"
source "$SOURCE/autoenv.zsh"
source "$SOURCE/docker.zsh"

# Libraries
source "$SOURCE/history.zsh"
source "$SOURCE/prompt.zsh"

# Load extra (if available
[[ -f "$SOURCE/extra.zsh" ]] && source "$SOURCE/extra.zsh"