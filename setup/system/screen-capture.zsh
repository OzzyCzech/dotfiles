#!/usr/bin/env zsh

###############################################################################
# Screen capture
###############################################################################

function set-screen-capture() {

  info "Screen capture setup"

  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true;
  ok "Disable shadow in screenshots"

  # Save screenshots to the ~/Downloads
  defaults write com.apple.screencapture location -string "${HOME}/Downloads"
  ok "Save screenshots to the ~/Downloads"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"
  ok "Save screenshots in PNG format"

  # Set screenshot filename
  defaults write com.apple.screencapture name -string "screenshot"
  ok "Set screenshot filename"

  # Disable datetime in screenshots filename
  defaults write com.apple.screencapture include-date -bool false
  ok "Disable datetime in screenshots filename"

  killall SystemUIServer &> /dev/null
}
