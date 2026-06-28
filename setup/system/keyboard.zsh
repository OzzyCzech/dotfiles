#!/usr/bin/env zsh

###############################################################################
# Keyboard
###############################################################################

# Keyboard access mode (Tab moves between text boxes and lists)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 1

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
