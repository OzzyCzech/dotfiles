name = $(shell git config user.name)
email = $(shell git config user.email)

# Synchronize do local directory
sync:
	rsync -arv --exclude=".git/" --exclude=".idea/" --exclude="icns/" --exclude=".DS_Store" --exclude="brew/" --exclude="install/" --exclude=*.md --exclude=*.terminal --exclude=Makefile . ~
	git config --global user.name "$(name)"
	git config --global user.email $(email)

install.brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	xargs -n1 -t brew tap < brew/tap.txt
	xargs -n1 -t brew install < brew/list.txt
	xargs -n1 -t brew install --cask < brew/cask-list.txt

install.ohmyzsh:
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

install: install.brew install.ohmyzsh
	touch ~/.extra
	echo "FINISH with: sh brew/brew.sh"
	
description:
	brew leaves --installed-on-request | xargs -n1 brew desc > install/installed.md

# Backup brew packages
backup:
	brew leaves --installed-on-request >  brew/list.txt
	brew list --cask >  brew/cask-list.txt
	brew tap > brew/tap.txt

.PHONY: sync backup install install.brew install.ohmyzsh