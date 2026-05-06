# Silence the doctor false-positive triggered by antidote-deferred plugins
# (e.g. zsh-syntax-highlighting kind:defer) that register precmd hooks after
# zoxide has initialized. Not an actual conflict — zoxide uses chpwd, the
# deferred plugin uses precmd — but the doctor warns about any post-init
# hook activity. See: https://github.com/ajeetdsouza/zoxide/issues
export _ZO_DOCTOR=0
eval "$(zoxide init zsh --cmd cd)"
