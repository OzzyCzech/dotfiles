#!/usr/bin/env bash

###############################################################################
# Screen Saver
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

killall "System Preferences" &> /dev/null