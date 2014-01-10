
#############################################################################
# current prompt
#############################################################################
# \d – Current date
# \t – Current time
# \h – Host name
# \# – Command number
# \u – User name
# \W – Current working directory (ie: Desktop/)
# \w – Current working directory, full path (ie: /Users/Admin/Desktop)
# export PS1="\u@\h\w: "
export PS1="\w: " 

#############################################################################
# git autocomplet and bash prompt
#############################################################################

source `brew --prefix git`/etc/bash_completion.d/git-completion.bash
source `brew --prefix git`/etc/bash_completion.d/git-prompt.sh

# configure git and prompt

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="git verbose legacy"
export PSORIG="$PS1" # pokud chcete zachovat puvodni PS1

PS1=$PSORIG'$(__git_ps1 "\[\033[01;31m\]%s \[\033[00m\]")'


# If you get error like: `Dubious ownership on file...` need to change rights:
# sudo chown root <file>
# sudo chmod 644 <filename>     


#############################################################################
# nginx aliases
#############################################################################

alias nginx-start="sudo nginx"
alias nginx-restart="sudo nginx -s reload"
alias nginx-stop="sudo nginx -s stop"

#############################################################################
# php-fpm aliases
#############################################################################

alias php-start="sudo launchctl load ~/Library/LaunchAgents/homebrew-php.josegonzalez.php55.plist"
alias php-stop="sudo launchctl unload ~/Library/LaunchAgents/homebrew-php.josegonzalez.php55.plist"
alias php-restart="php-stop && php-start"

#############################################################################
# mongo aliases
#############################################################################

alias mongo-start="sudo launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist"
alias mongo-stop="sudo launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist"
alias mongo-restart="mongo-stop && mongo-start"

#############################################################################
# mysql
#############################################################################

alias mysql-start="sudo mysql.server start"
alias mysql-stop="sudo mysql.server stop"
alias mysql-restart="mysql-stop && mysql-start"

#############################################################################
# memcached
#############################################################################

alias memcached-start="sudo launchctl load ~/Library/LaunchAgents/homebrew.mxcl.memcached.plist"
alias memcached-stop="sudo launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.memcached.plist"
alias memcached-restart="memcached-stop && memcached-start"

#############################################################################
# aliases
#############################################################################

alias drives="df -h" # list all drives
alias listen="sudo lsof -i -P | grep -i \"listen\"" # listen on ports


alias preview="open -a '$PREVIEW'"
alias xcode="open -a '/Developer/Applications/Xcode.app'"
alias safari="open -a safari"
alias firefox="open -a firefox"
alias opera="open -a opera"
alias chrome="open -a google\ chrome"
alias f='open -a Finder'
alias please=sudo

#############################################################################
# List aliases
#############################################################################

# List all files colorized in long format
alias l="ls -l --color"

# List all files colorized in long format, including dot files
alias la="ls -la --color"

# List all alias
alias ll="ls -la" # ll alias

# List only directories
alias lsd='ls -l | grep "^d"'

# list alias with -G
alias ls="command ls -G"

#############################################################################
# Others
#############################################################################

# Enhanced WHOIS lookups
alias whois="whois -h whois-servers.net"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache"

# File size
alias fs="stat -f \"%z bytes\""

#############################################################################
# Prefer US English and use UTF-8
#############################################################################

export LC_ALL="en_US.UTF-8"
export LANG="en_US"

#############################################################################
# path
#############################################################################

export PATH="/usr/local/Cellar/coreutils/8.21/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH"

#############################################################################
# bash history size
#############################################################################

export HISTCONTROL=erasedups
export HISTSIZE=10000
shopt -s histappend

#############################################################################
# Change Terminal tab name to dir basename
#############################################################################

PROMPT_COMMAND='echo -n -e "\033]0;${PWD##*/}\007"'


