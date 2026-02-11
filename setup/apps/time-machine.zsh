#!/usr/bin/env zsh

###############################################################################
# Time Machine
###############################################################################

# Disable local Time Machine backups
# hash tmutil &> /dev/null && sudo tmutil disablelocal

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
