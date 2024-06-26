#!/usr/bin/env zsh

###############################################################################
# Screen Saver
###############################################################################
function set-screen-saver() {

  info "Screen saver settings"

  # Disable screen saver
  defaults -currentHost write com.apple.screensaver idleTime -int 0
  ok "Screen saver disabled"

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  ok "Require password immediately"

  killall "System Preferences" &> /dev/null
}