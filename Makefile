name := $(shell git config user.name)
email := $(shell git config user.email)
username := $(shell git config user.username)

install:
	touch ~/.hushlogin

	rsync -a configs/.config/ ~/.config/
	rsync -a .gitconfig ~/

	ln -sf ~/.dotfiles/.ackrc ~/.ackrc
	ln -sf ~/.dotfiles/.gitignore ~/.gitignore
	ln -sf ~/.dotfiles/.zshrc ~/.zshrc
	ln -sf ~/.dotfiles/.zsh_plugins.txt ~/.zsh_plugins.txt
	ln -sf ~/.dotfiles/zsh ~/.zsh
	ln -sf ~/.dotfiles/bin ~/.bin

	git config --global user.name "$(name)"
	git config --global user.email "$(email)"
	git config --global user.username "$(username)"

	@echo "\nDone! Run 'exec zsh' to reload your shell."

utils:
	swiftc utils/del.swift -o bin/del
	swiftc utils/passgen.swift -o bin/passgen
	swiftc utils/encode64.swift -o bin/encode64
	swiftc utils/backup.swift -o bin/backup

completions:
	pnpm completion zsh > zsh/_pnpm

backup: backup.apps backup.configs

backup.configs:
	backup -c backup.json configs
	plutil -convert xml1 configs/Library/Preferences/com.apple.Terminal.plist

backup.apps:
	brew leaves --installed-on-request > apps/brew-list.txt
	brew list --cask > apps/brew-list-cask.txt
	brew tap > apps/brew-tap.txt
	mas list > apps/mas-list.txt

.PHONY: $(MAKECMDGOALS)