SOURCE=${0%/*}

# Paths
source "$SOURCE/paths.zsh"

# Aliases
source "$SOURCE/aliases.zsh"

# Functions
source "$SOURCE/functions.zsh"

# Load extra (if available
[[ -f "$SOURCE/extra.zsh" ]] && source "$SOURCE/extra.zsh"