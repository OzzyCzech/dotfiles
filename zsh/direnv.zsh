# Load .env (and .envrc) of the current directory and unload it on leave.
# Config: config/direnv/direnv.toml. The first export runs at the top of
# .zshrc, before the Powerlevel10k instant prompt.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
