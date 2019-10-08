export ZSH="$HOME/.oh-my-zsh"

# https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/git
# https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/yarn
# https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/httpie
# https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/dotenv
plugins=(git yarn httpie dotenv)

source $ZSH/oh-my-zsh.sh

#############################################################################
# Prefer US English and use UTF-8
#############################################################################

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#############################################################################
# Homebrew
#############################################################################

export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH"

# Homebrew GitHub API rate limit exceeded
# see https://github.com/settings/tokens put new token to follow line and uncomment
# export HOMEBREW_GITHUB_API_TOKEN=XXXXXX

#############################################################################
# Homebrew
#############################################################################

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases, and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{exports,aliases,functions,extra}; do
	[[ -r "$file" ]] && source "$file"
done
unset file