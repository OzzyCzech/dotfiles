#!/usr/bin/env zsh

###############################################################################
# Terminal                                                                    #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# show scroll bar only when scrolling in Terminal
defaults write com.apple.Terminal AppleShowScrollbars -string "WhenScrolling"

# Set Startup Window Settings
#defaults write com.apple.Terminal "Startup Window Settings" -string "OzzyCzech"

# Set Default Window Settings
#defaults write com.apple.Terminal "Default Window Settings" -string "OzzyCzech"

killall Terminal &> /dev/null
