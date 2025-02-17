#!/usr/bin/env zsh

###############################################################################
# Dock
###############################################################################

# Set the icon size of Dock items to 48 pixels
defaults write com.apple.Dock tilesize -int 48

# Immutable dock size
defaults write com.apple.Dock size-immutable -bool yes

# Disable recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Automatically hide and show the Dock
# defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

###############################################################################
# Dock hot corners
###############################################################################

# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# 14: Quick note

# Top left screen corner → not set
defaults write com.apple.dock wvous-tl-corner --int 0
defaults write com.apple.dock wvous-tl-modifier --int 0

# Top right screen corner → not set
defaults write com.apple.dock wvous-tr-corner --int 0
defaults write com.apple.dock wvous-tr-modifier --int 0

# Top right corner → not set
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Bottom left corner → Lock screen
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# Show current settings
# defaults read com.apple.dock | grep wvous

killall Dock &> /dev/null
