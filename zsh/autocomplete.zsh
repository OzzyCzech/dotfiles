# Tab completion of SSH hostnames, including files in ~/.ssh/conf.d
# Note ~/.ssh/config needs the directive Include ~/.ssh/conf.d/* for this to work
# See https://www.codyhiar.com/blog/zsh-autocomplete-with-ssh-config-file/

# Highlight the current autocomplete option
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better SSH/Rsync/SCP Autocomplete
zstyle ':completion:*:(scp|rsync):*' tag-order ' hosts:-ipaddr:ip\ address hosts:-host:host files'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Allow for autocomplete to be case insensitive
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  '+l:|?=** r:|?=**'

# see https://github.com/ohmyzsh/ohmyzsh/issues/7284
zstyle ':completion:*:ssh:*' hosts off
# SSH autocomplete
autoload -Uz compinit && compinit -i