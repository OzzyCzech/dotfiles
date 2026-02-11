#!/usr/bin/env zsh

###############################################################################
# Software Update
###############################################################################

function set-software-updates() {

  info "Software update settings"

  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  ok "Enable the automatic update check"

  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
  ok "Check for software updates daily, not just once per week"

  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
  ok "Download newly available updates in background"

  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
  ok "Install critical updates automatically"

  killall "App Store" &> /dev/null
}
