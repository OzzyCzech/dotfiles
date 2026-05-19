# Directory shortcuts
alias des="cd ~/Desktop"
alias dwn="cd ~/Downloads"
alias doc="cd ~/Documents"
alias work="cd /Volumes/Work"

# Browsers
alias safari="/Applications/Safari.app/Contents/MacOS/Safari"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias firefox="/Applications/Firefox.app/Contents/MacOS/firefox"

# Print website to pdf or png
# e.g. print-to-pdf https://google.com ~/Downloads/google.pdf
# e.g. print-to-png https://google.com ~/Downloads/google.png
print-to-pdf() { chrome --headless --disable-gpu --no-pdf-header-footer --no-margins --run-all-compositor-stages-before-draw --print-to-pdf="${2:-print.pdf}" "$1" > /dev/null 2>&1; }
print-to-png() { chrome --headless --disable-gpu --hide-scrollbars --virtual-time-budget=2000 --window-size=1920,1428 --screenshot="${2:-screenshot.png}" "$1" > /dev/null 2>&1; }

# Generic helpers
alias fs="stat -f \"%z bytes\""                          # file size
type -f hd > /dev/null || alias hd="hexdump -C"          # canonical hex dump
type -f md5sum > /dev/null || alias md5sum="md5"         # macOS has no md5sum

# bat = cat with syntax highlighting. Auto-detects pipes (acts like plain
# cat when output is not a TTY), so scripts/pipelines stay intact.
command -v bat > /dev/null && alias cat="bat --paging=never"
