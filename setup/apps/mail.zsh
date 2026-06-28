#!/usr/bin/env zsh

###############################################################################
# Mail
###############################################################################

# Disable link previews in messages
defaults write com.apple.mail AddLinkPreviews -bool false

killall "Mail" &> /dev/null
