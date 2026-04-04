source ~/.zsh/autocomplete.zsh

# Install the Antidote plugin manager
# see https://getantidote.github.io/
source $(brew --prefix antidote)/share/antidote/antidote.zsh
antidote load

# Force xterm-256color terminal for all terminals
export TERM=xterm-256color

# Paths
source ~/.zsh/paths.zsh

# Aliases
source ~/.zsh/aliases.zsh

source ~/.zsh/eza.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/autoenv.zsh
source ~/.zsh/docker.zsh
source ~/.zsh/ai.zsh

# Libraries
source ~/.zsh/history.zsh
source ~/.zsh/prompt.zsh

# Load extra (if available)
[[ -f ~/.zsh/extra.zsh ]] && source ~/.zsh/extra.zsh