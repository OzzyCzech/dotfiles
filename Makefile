name = $(shell git config user.name)
email = $(shell git config user.email)
username = $(shell git config user.username)

# Synchronize do local directory
sync:
	rclone copy . ~ --include={.ackrc,.aliases,.exports,.functions,.gitconfig,.gitignore,.zshrc,.config/yt-dlp.conf}
	git config --global user.name "$(name)"
	git config --global user.email $(email)
	git config --global user.username $(username)

install.brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)""


install.ohmyzsh:
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

install: install.brew install.ohmyzsh
	touch ~/.extra

description:
	brew leaves --installed-on-request | xargs -n1 brew desc > install/installed.md

# Backup brew packages
backup.brew:
	brew leaves --installed-on-request >  brew/brew-list.txt
	brew list --cask >  brew/brew-list-cask.txt
	brew tap > brew/brew-tap.txt

backup.terminal:
	cp ~/Library/Preferences/com.apple.Terminal.plist terminal/com.apple.Terminal.plist
	plutil -convert xml1 terminal/com.apple.Terminal.plist

.PHONY: install sync backup.brew backup.terminal install.brew install.ohmyzsh
