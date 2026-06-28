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

	# Symlink ~/.claude entries (global instructions, settings, commands, skills)
	mkdir -p ~/.claude
	ln -sf ~/.dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
	ln -sf ~/.dotfiles/claude/settings.json ~/.claude/settings.json
	ln -sf ~/.dotfiles/claude/commands ~/.claude/commands
	ln -sf ~/.dotfiles/claude/skills ~/.claude/skills

	# Symlink ~/.config entries (per-file; apps create other files in these dirs)
	mkdir -p ~/.config/zed ~/.config/ghostty ~/.config/cmux
	ln -sf ~/.dotfiles/config/zed/keymap.json ~/.config/zed/keymap.json
	ln -sf ~/.dotfiles/config/zed/settings.json ~/.config/zed/settings.json
	ln -sf ~/.dotfiles/config/ghostty/config ~/.config/ghostty/config
	ln -sf ~/.dotfiles/config/cmux/cmux.json ~/.config/cmux/cmux.json
	ln -sf ~/.dotfiles/config/yt-dlp.conf ~/.config/yt-dlp.conf

	@echo "\nDone! Run 'exec zsh' to reload your shell."

utils:
	swiftc utils/del.swift -o bin/del
	swiftc utils/passgen.swift -o bin/passgen
	swiftc utils/encode64.swift -o bin/encode64

completions:
	pnpm completion zsh > zsh/_pnpm

apps-backup:
	brew leaves --installed-on-request > apps/brew-list.txt
	brew list --cask > apps/brew-list-cask.txt
	brew tap > apps/brew-tap.txt
	mas list > apps/mas-list.txt

.PHONY: $(MAKECMDGOALS)
