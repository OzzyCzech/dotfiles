name = $(shell git config user.name)
email = $(shell git config user.email)

sync:	
	rsync -arv --exclude=".git/" --exclude=".DS_Store" --exclude="brew/" --exclude="install/" --exclude=*.md --exclude=Makefile . ~
	git config --global user.name "$(name)"
	git config --global user.email $(email)

install:
	touch ~/.extra
	cd brew && sh brew.sh

backup:
	brew leaves >  brew/list.txt
	brew cask list >  brew/cask-list.txt
	brew tap > brew/tap.txt

.PHONY: sync backup install