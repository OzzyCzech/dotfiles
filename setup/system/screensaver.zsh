#!/usr/bin/env zsh

###############################################################################
# Screen Saver
###############################################################################
function set-screen-saver() {

  info "Screen saver settings"

  # Start screen saver after 5 minutes
  defaults -currentHost write com.apple.screensaver idleTime -int 300
  ok "Screen saver after 5 minutes"

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  ok "Require password immediately"

  killall "System Settings" &> /dev/null
}
