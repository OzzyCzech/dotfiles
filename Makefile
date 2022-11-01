name = $(shell git config user.name)
email = $(shell git config user.email)
username = $(shell git config user.username)

# Synchronize do local directory
sync:
	rclone copy . ~ --include={/.ackrc,/.aliases,/.exports,/.functions,/.gitconfig,/.gitignore,/.zshrc/,.config/yt-dlp.conf}
	git config --global user.name "$(name)"
	git config --global user.email $(email)
	git config --global user.username $(username)

install.brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	xargs -n1 -t brew tap < install/brew-tap.txt
	xargs -n1 -t brew install < install/brew-list.txt
	xargs -n1 -t brew install --cask < install/brew-list-cask.txt

install.ohmyzsh:
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

install: install.brew install.ohmyzsh
	touch ~/.extra
	echo "FINISH with: sh brew/brew.sh"
	
description:
	brew leaves --installed-on-request | xargs -n1 brew desc > install/installed.md

# Backup brew packages
backup:
	brew leaves --installed-on-request >  install/brew-list.txt
	brew list --cask >  install/brew-list-cask.txt
	brew tap > install/brew-tap.txt

.PHONY: sync backup install install.brew install.ohmyzsh