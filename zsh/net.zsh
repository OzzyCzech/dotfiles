# IP addresses
ip-local() { ipconfig getifaddr en0 || ipconfig getifaddr en1; }
ip-v4() { curl -4 -fsS ifconfig.co; echo; }
ip-v6() { curl -6 -fsS ifconfig.co; echo; }
ip() { echo "IPv4: $(ip-v4)\nIPv6: $(ip-v6)\nLocal: $(ip-local)"; }
alias ips="ifconfig -a | grep -oE '\d+\.\d+\.\d+\.\d+' | sort | uniq"

# Flush Directory Service cache
alias dns-flush="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder;"

# List all apps on listening ports
alias listen="sudo lsof -iTCP -sTCP:LISTEN -n -P"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# URL-encode strings
url-encode() { printf '%s' "$1" | jq -Rr @uri; }
