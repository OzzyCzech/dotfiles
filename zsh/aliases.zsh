alias des="cd ~/Desktop"
alias dwn="cd ~/Downloads"
alias doc="cd ~/Documents"
alias work="cd /Volumes/Work"

########################################################################################################################
# System
########################################################################################################################

alias drives="df -h" # list all drives

########################################################################################################################
# Browsers
########################################################################################################################

alias safari="/Applications/Safari.app/Contents/MacOS/Safari"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias firefox="/Applications/Firefox.app/Contents/MacOS/firefox"

########################################################################################################################
# Print website to pdf
# function accept two parameters first is url and second is optional filename
# e.g. print-to-pdf https://google.com ~/Downloads/google.pdf
# e.h. print-to-png https://google.com ~/Downloads/google.png
########################################################################################################################

print-to-pdf() { chrome --headless --disable-gpu --no-pdf-header-footer --no-margins --run-all-compositor-stages-before-draw --print-to-pdf="${2:-print.pdf}" "$1" > /dev/null 2>&1; }
print-to-png() { chrome --headless --disable-gpu --hide-scrollbars --virtual-time-budget=2000 --window-size=1920,1428 --screenshot="${2:-screenshot.png}" "$1" > /dev/null 2>&1; }

########################################################################################################################
# Package management
########################################################################################################################

alias pup="npx taze minor --write --install --interactive --include-locked"
alias pupr="npx taze minor --write --recursive --install --interactive --include-locked --mirror"
alias pupg="npx taze major --write --install --interactive --include-locked --global"
alias npm-list-globals="npm list -g --depth 0"
alias composer="COMPOSER_IGNORE_PLATFORM_REQS=1 composer"
alias pip="python3 -m pip"

########################################################################################################################
# Internet
########################################################################################################################

# IP addresses
alias ip-local="ipconfig getifaddr en1"
ip-v4() { dig @resolver1.opendns.com A "${1:-myip.opendns.com}" +short -4; }
ip-v6() { dig @resolver1.opendns.com AAAA "${1:-myip.opendns.com}" +short -6; }
ip() { echo "IPv4: $(ip-v4)\nIPv6: $(ip-v6)\nLocal: $(ip-local)"; }
alias ips="ifconfig -a | grep -oE '\d+\.\d+\.\d+\.\d+' | sort | uniq"

# Enhanced WHOIS lookups
alias whois="whois -h whois-servers.net"

# Flush Directory Service cache
alias dns-flush="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder;"

########################################################################################################################
# Network
########################################################################################################################

# list all apps on ports
alias listen="sudo lsof -iTCP -sTCP:LISTEN -n -P"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Canonical hex dump; some systems have this symlinked
type -f hd > /dev/null || alias hd="hexdump -C"

# OS X has no `md5sum`, so use `md5` as a fallback
type -f md5sum > /dev/null || alias md5sum="md5"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '.DS_Store' -ls -delete"

# File size
alias fs="stat -f \"%z bytes\""

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Show/hide hidden files in Finder
alias show-hidden-files="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide-hidden-files="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# URL-encode strings
alias url-encode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))"'
