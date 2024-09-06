name = $(shell git config user.name)
email = $(shell git config user.email)
username = $(shell git config user.username)

install:
	touch ~/.hushlogin
	mkdir -p ~/.config && cp -R config/ ~/.config/

	cp -R {.ackrc,.gitconfig,.gitignore,.zshrc,.zsh_plugins.txt} ~
	rm -rf ~/.zsh/ && cp -R zsh/ ~/.zsh/
	mkdir -p ~/.bin && cp -R bin/* ~/.bin

	git config --global user.name "$(name)"
	git config --global user.email $(email)
	git config --global user.username $(username)

utils:
	swiftc utils/trash.swift -o ~/.bin/trash

backup: backup.brew backup.terminal

backup.brew:
	brew leaves --installed-on-request >  brew/brew-list.txt
	brew list --cask >  brew/brew-list-cask.txt
	brew tap > brew/brew-tap.txt

backup.terminal:
	cp ~/Library/Preferences/com.apple.Terminal.plist terminal/com.apple.Terminal.plist
	plutil -convert xml1 terminal/com.apple.Terminal.plist

.PHONY: $(MAKECMDGOALS)