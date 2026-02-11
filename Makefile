name := $(shell git config user.name)
email := $(shell git config user.email)
username := $(shell git config user.username)

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
	swiftc utils/del.swift -o ~/.bin/del
	swiftc utils/password.swift -o ~/.bin/password
	swiftc utils/encode64.swift -o ~/.bin/encode64

backup: backup.apps backup.terminal

backup.zed.settings:
	cp ~/.config/zed/settings.json config/zed/settings.json

backup.apps:
	brew leaves --installed-on-request > apps/brew-list.txt
	brew list --cask > apps/brew-list-cask.txt
	brew tap > apps/brew-tap.txt
	mas list > apps/mas-list.txt

backup.terminal:
	cp ~/Library/Preferences/com.apple.Terminal.plist terminal/com.apple.Terminal.plist
	plutil -convert xml1 terminal/com.apple.Terminal.plist

.PHONY: $(MAKECMDGOALS)