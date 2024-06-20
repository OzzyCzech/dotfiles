#!/usr/bin/env zsh
###############################################################################
# TextEdit                                                                     #
###############################################################################

# Disable smart quotes as they’re annoying when typing code
defaults write com.apple.TextEdit SmartQuotes -int 0

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

killall TextEdit &> /dev/null
