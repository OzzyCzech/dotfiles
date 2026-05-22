install:
	touch ~/.hushlogin

	# Symlink dotfiles (git)
	ln -sf ~/.dotfiles/.gitignore_global ~/.gitignore_global
	git config --global core.excludesfile ~/.gitignore_global
	ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig

	# Symlink zsh config
	ln -sf ~/.dotfiles/.zshrc ~/.zshrc
	ln -sf ~/.dotfiles/.zsh_plugins.txt ~/.zsh_plugins.txt

	# Symlink powerlevel10k config
	ln -sf ~/.dotfiles/.p10k.zsh ~/.p10k.zsh

	# Symlink zprofile
	ln -sf ~/.dotfiles/.zprofile ~/.zprofile

	# Symlink zsh directories
	ln -sf ~/.dotfiles/zsh ~/.zsh
	ln -sf ~/.dotfiles/bin ~/.bin

	# Symlink ~/.config entries
	mkdir -p ~/.config
	ln -sf ~/.dotfiles/config/zed ~/.config/zed
	ln -sf ~/.dotfiles/config/ghostty ~/.config/ghostty
	ln -sf ~/.dotfiles/config/cmux ~/.config/cmux
	ln -sf ~/.dotfiles/config/yt-dlp.conf ~/.config/yt-dlp.conf

	@echo "\nDone! Run 'exec zsh' to reload your shell."

utils:
	swiftc utils/del.swift -o bin/del
	swiftc utils/passgen.swift -o bin/passgen
	swiftc utils/encode64.swift -o bin/encode64

completions:
	pnpm completion zsh > zsh/_pnpm

apps:
	brew leaves --installed-on-request > apps/brew-list.txt
	brew list --cask > apps/brew-list-cask.txt
	brew tap > apps/brew-tap.txt
	mas list > apps/mas-list.txt

.PHONY: $(MAKECMDGOALS)
