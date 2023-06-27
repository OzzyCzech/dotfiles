#!/usr/bin/env bash

###############################################################################
# Screencapture                                                                    #
###############################################################################

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Save screenshots to the ~/Downloads
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable datetime in screenshots filename
defaults write com.apple.screencapture include-date -bool false

killall SystemUIServer &> /dev/null
