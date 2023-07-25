export ZSH="$HOME/.oh-my-zsh"

#############################################################################
# ZSH theme
# https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#############################################################################

ZSH_THEME="robbyrussell"

#############################################################################
# ZSH plugins
#
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/yarn
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/httpie
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rsync
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/cp
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/composer
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/forklift
#############################################################################

plugins=(
    git
    yarn
    httpie
    dotenv
    rsync
    docker
    cp
    composer
    forklift
)

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
# Setup path to binaries
#############################################################################

export PATH="/usr/local/bin:/usr/local/sbin:$HOME/.dotfiles/bin:$PATH"

# Homebrew GitHub API rate limit exceeded
# see https://github.com/settings/tokens put new token to follow line and uncomment
# export HOMEBREW_GITHUB_API_TOKEN=XXXXXX

#############################################################################
# ssh config autocomplete from ~/.ssh/config file
# https://github.com/ohmyzsh/ohmyzsh/issues/7284
#############################################################################

zstyle ':completion:*:ssh:*' hosts off

#############################################################################
# Automatic update without confirmation prompt
# https://github.com/ohmyzsh/ohmyzsh#getting-updates
#############################################################################

zstyle ':omz:update' mode auto

#############################################################################
# Change default ZSH_COMPDUMP directory to ZSH_CACHE_DIR
# https://github.com/ohmyzsh/ohmyzsh/pull/9090
#############################################################################

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

#############################################################################
# ZSH prompt
#############################################################################
# When a partial line is preserved, by default you will see an inverse+bold
# character at the end of the partial line: a ‘%’ for a normal user or a ‘#’
# for root. If set, the shell parameter PROMPT_EOL_MARK can be used to
# customize how the end of partial lines are shown.
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Prompting

setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=""

#############################################################################
# Other settings
#############################################################################
# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases, and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
#############################################################################

for file in ~/.{exports,aliases,functions,extra}; do
	[[ -r "$file" ]] && source "$file"
done
unset file
