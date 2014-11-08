#############################################################################
# load other files
#############################################################################

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

#############################################################################
# nginx aliases
#############################################################################

alias nginx-start="sudo nginx"
alias nginx-restart="sudo nginx -s reload"
alias nginx-stop="sudo nginx -s stop"

#############################################################################
# php-fpm aliases
#############################################################################

alias php-start="sudo launchctl load ~/Library/LaunchAgents/homebrew.mxcl.php56.plist"
alias php-stop="sudo launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.php56.plist"
alias php-restart="php-stop && php-start"

#############################################################################
# mongo aliases
#############################################################################

alias mongo-start="sudo launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist"
alias mongo-stop="sudo launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist"
alias mongo-restart="mongo-stop && mongo-start"

#############################################################################
# redis
#############################################################################

alias redis-start="sudo launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist"
alias redis-stop="sudo launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.redis.plist"
alias redis-restart="redis-stop && redis-start"

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
# Start everything :-)
#############################################################################

alias jarvis="memcached-start && mysql-start && redis-start && mongo-start && php-start && nginx-start"
alias jarvis-stop="memcached-stop && mysql-stop && redis-stop && mongo-stop && php-stop && nginx-stop"
alias jarvis-restart="memcached-restart && mysql-restart && redis-restart && mongo-restart && php-restart && nginx-restart"

#############################################################################
# aliases
#############################################################################

alias drives="df -h" # list all drives
alias listen="sudo lsof -i -P | grep -i \"listen\"" # listen all apps on ports
alias preview="open -a '$PREVIEW'"
alias xcode="open -a '/Developer/Applications/Xcode.app'"
alias safari="open -a safari"
alias firefox="open -a firefox"
alias opera="open -a opera"
alias chrome="open -a google\ chrome"
alias f='open -a Finder'
alias please="sudo"
alias reload="source ~/.bash_profile"
alias yolo="history -c && clear"
alias apt-get="brew" # admins :-)

#############################################################################
# List aliases
#############################################################################

# List all files colorized in long format
alias l="ls -l --color"

# List all files colorized in long format, including dot files
alias la="ls -la --color"

# List all alias
alias ll="ls -lha" # ll alias

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

export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH"