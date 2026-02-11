#!/usr/bin/env zsh

###############################################################################
# Set Lock Screen Message
###############################################################################

function set-lock-message() {
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$@"
}
