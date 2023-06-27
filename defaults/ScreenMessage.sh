#!/usr/bin/env bash

###############################################################################
# Set Lock Screen Message
###############################################################################

if [[ $# -gt 0 ]]
  then sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$1"
  else echo Please provide Lock Screen Message as argument
fi