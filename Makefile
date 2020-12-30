name = $(shell git config user.name)
email = $(shell git config user.email)

# Synchronize do local directory
sync:
	rsync -arv --exclude=".git/" --exclude=".idea/" --exclude=".DS_Store" --exclude="brew/" --exclude="install/" --exclude=*.md --exclude=Makefile . ~
	git config --global user.name "$(name)"
	git config --global user.email $(email)

install.brew:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

install.ohmyzsh:
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

install: install.brew install.ohmyzsh
	touch ~/.extra

	echo "FINISH with: sh brew/brew.sh"
	
# Backup brew packages
backup:
	brew leaves >  brew/list.txt
	brew list --cask >  brew/cask-list.txt
	brew tap > brew/tap.txt

.PHONY: sync backup install install.brew install.ohmyzsh