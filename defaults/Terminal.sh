#!/usr/bin/env bash

###############################################################################
# Terminal                                                                    #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# show scroll bar only when scrolling in Terminal
defaults write com.apple.Terminal AppleShowScrollbars -string "WhenScrolling"

killall Terminal &> /dev/null