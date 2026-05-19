# Enable Powerlevel10k instant prompt. Must stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.zsh/autocomplete.zsh

# Install the Antidote plugin manager
# see https://getantidote.github.io/
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load

# Force xterm-256color terminal for all terminals
export TERM=xterm-256color

# Paths
source ~/.zsh/paths.zsh

# Aliases
source ~/.zsh/aliases.zsh
source ~/.zsh/net.zsh
source ~/.zsh/mac.zsh
source ~/.zsh/pkg.zsh

source ~/.zsh/eza.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/autoenv.zsh
source ~/.zsh/docker.zsh
source ~/.zsh/bun.zsh
source ~/.zsh/ai.zsh

# Libraries
source ~/.zsh/history.zsh
source ~/.zsh/prompt.zsh

# Load extra (if available)
[[ -f ~/.zsh/extra.zsh ]] && source ~/.zsh/extra.zsh

# zoxide must be initialized last so its chpwd hook is registered after
# any other plugin/library that touches chpwd (autoenv, prompt, etc.).
source ~/.zsh/zoxide.zsh