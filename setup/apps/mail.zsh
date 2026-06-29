#!/usr/bin/env zsh

###############################################################################
# Mail
###############################################################################

# --- Viewing -----------------------------------------------------------------

# Disable link previews in messages
defaults write com.apple.mail AddLinkPreviews -bool false

# Preview pane below the message list (off = side-by-side)
defaults write com.apple.mail BottomPreview -bool false

# Show contact photos in the message list
defaults write com.apple.mail EnableContactPhotos -bool true

# Don't show To/Cc label in the message list
defaults write com.apple.mail EnableToCcInMessageList -bool false

# Single-line message list layout
defaults write com.apple.mail ColumnLayoutMessageList -bool false

# Default header detail level
defaults write com.apple.mail HeaderDetail -string "Default"

# Direction for "next message" navigation
defaults write com.apple.mail MessageListNextMessageDirection -int 1

# --- Threading & flags -------------------------------------------------------

# Organize messages by conversation (threading) by default
defaults write com.apple.mail ThreadingDefault -bool true

# Don't show flag column in the message list
defaults write com.apple.mail MailShowFlags -bool false

# Flag color to display
defaults write com.apple.mail FlagColorToDisplay -int 1

# --- Compose headers ---------------------------------------------------------

# Show Cc header, hide Bcc / Reply-To / Priority controls
defaults write com.apple.mail ShowCcHeader -bool true
defaults write com.apple.mail ShowBccHeader -bool false
defaults write com.apple.mail ShowReplyToHeader -bool false
defaults write com.apple.mail ShowPriorityControl -bool false

# --- Spelling ----------------------------------------------------------------

# Check spelling as you type
defaults write com.apple.mail SpellCheckingBehavior -string "InlineSpellCheckingEnabled"
defaults write com.apple.mail WebContinuousSpellCheckingEnabled -bool true

# --- Fonts -------------------------------------------------------------------

defaults write com.apple.mail NSFont -string "Helvetica"
defaults write com.apple.mail NSFontSize -int 14
defaults write com.apple.mail NSFixedPitchFont -string "Menlo-Regular"
defaults write com.apple.mail NSFixedPitchFontSize -int 14

# --- Search & indexing -------------------------------------------------------

# Include Trash when searching / indexing
defaults write com.apple.mail IndexTrash -bool true

# Check for new mail manually (-1 = manual)
defaults write com.apple.mail PollTime -string "-1"

killall "Mail" &> /dev/null
