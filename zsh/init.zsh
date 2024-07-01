SOURCE=${0%/*}

# Paths
source "$SOURCE/paths.zsh"

# Aliases
source "$SOURCE/eza.zsh"
source "$SOURCE/aliases.zsh"

# Functions
source "$SOURCE/functions.zsh"
source "$SOURCE/password.zsh"
source "$SOURCE/encode64.zsh"
source "$SOURCE/autoenv.zsh"

# Libraries
source "$SOURCE/history.zsh"
source "$SOURCE/prompt.zsh"

# Load extra (if available
[[ -f "$SOURCE/extra.zsh" ]] && source "$SOURCE/extra.zsh"