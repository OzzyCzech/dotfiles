export ZSH="$HOME/.oh-my-zsh"

# https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/yarn
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/httpie
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rsync
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/cp
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/composer
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/forklift
plugins=(git yarn httpie dotenv rsync docker cp composer forklift)

source $ZSH/oh-my-zsh.sh

#############################################################################
# Prefer US English and use UTF-8
#############################################################################

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#############################################################################
# Editor
#############################################################################

export EDITOR=/usr/bin/nano
export VISUAL=/usr/bin/nano

#############################################################################
# Homebrew
#############################################################################

export PATH="/usr/local/opt/python/libexec/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# Homebrew GitHub API rate limit exceeded
# see https://github.com/settings/tokens put new token to follow line and uncomment
# export HOMEBREW_GITHUB_API_TOKEN=XXXXXX

#############################################################################
# Keypad
#############################################################################

# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[On" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * / =
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"
bindkey -s "^[OX" "="

#############################################################################
# Homebrew
#############################################################################

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases, and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{exports,aliases,functions,extra}; do
	[[ -r "$file" ]] && source "$file"
done
unset file