name = $(shell git config user.name)
email = $(shell git config user.email)
username = $(shell git config user.username)

# Synchronize do local directory
sync:
	mkdir -p ~/.config/ ~/.config/zed/
	cp .config/zed/settings.json ~/.config/zed/settings.json
	cp .config/yt-dlp.conf ~/.config/yt-dlp.conf

	cp {.ackrc,.aliases,.exports,.functions,.gitconfig,.gitignore,.zshrc} ~

	touch ~/.config/rclone/rclone.conf
	touch ~/.extra

	git config --global user.name "$(name)"
	git config --global user.email $(email)
	git config --global user.username $(username)

install.brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

install.ohmyzsh:
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

install: install.brew install.ohmyzsh
	touch ~/.extra

# Backup brew packages
backup.brew:
	brew leaves --installed-on-request >  brew/brew-list.txt
	brew list --cask >  brew/brew-list-cask.txt
	brew tap > brew/brew-tap.txt

backup.terminal:
	cp ~/Library/Preferences/com.apple.Terminal.plist terminal/com.apple.Terminal.plist
	plutil -convert xml1 terminal/com.apple.Terminal.plist

.PHONY: $(MAKECMDGOALS)