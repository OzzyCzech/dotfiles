# Always use color output for `ls`
# https://eza.rocks/

if ! command -v eza &>/dev/null; then
  print 'eza not found - https://eza.rocks. Please install eza before.' >&2
  return 1
fi

alias ls='eza --group-directories-first --color-scale=all --color-scale-mode=gradient --octal-permissions'

# Show in tree view
alias lt='ls --tree'
alias tree='lt'

# Short, all files
alias l='ls --all'
# Short, only directories
alias ld='l --only-dirs'

# Long, file size prefixes, git status
alias ll='ls --long --all'
# Long, all files, . & ..
alias la='ll --all --all'

# Long, sort changed
alias ls-changed='la --sort=changed'
# Long, sort modified
alias ls-modified='la --sort=modified'
# Long, sort size
alias ls-size='la --sort=size'
# Long, sort extension
alias ls-extension='la --sort=extension'


