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

	# Download the status line from https://github.com/OzzyCzech/claude-code-statusline
	# (through a temp file: a failed download keeps the current script, mv replaces an old symlink)
	curl -fsSL -o ~/.claude/statusline.sh.tmp https://raw.githubusercontent.com/OzzyCzech/claude-code-statusline/main/statusline.sh
	mv ~/.claude/statusline.sh.tmp ~/.claude/statusline.sh

	# Symlink ~/.config entries (per-file; apps create other files in these dirs)
	mkdir -p ~/.config/zed ~/.config/ghostty ~/.config/cmux ~/.config/direnv
	ln -sf ~/.dotfiles/config/zed/keymap.json ~/.config/zed/keymap.json
	ln -sf ~/.dotfiles/config/zed/settings.json ~/.config/zed/settings.json
	ln -sf ~/.dotfiles/config/ghostty/config ~/.config/ghostty/config
	ln -sf ~/.dotfiles/config/cmux/cmux.json ~/.config/cmux/cmux.json
	ln -sf ~/.dotfiles/config/yt-dlp.conf ~/.config/yt-dlp.conf
	ln -sf ~/.dotfiles/config/direnv/direnv.toml ~/.config/direnv/direnv.toml

	@echo "\nDone! Run 'exec zsh' to reload your shell."

utils:
	swiftc utils/del.swift -o bin/del
	swiftc utils/passgen.swift -o bin/passgen
	swiftc utils/encode64.swift -o bin/encode64

apps-backup:
	brew bundle dump --file=apps/Brewfile --force

apps-install:
	brew bundle install --file=apps/Brewfile

.PHONY: $(MAKECMDGOALS)
