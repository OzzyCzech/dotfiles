#!/usr/bin/env bash

###############################################################################
# ImageCapture
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

killall "Photos" &> /dev/null
