sync:	
	rsync -arv --exclude=".git/" --exclude=".DS_Store" --exclude="brew/" --exclude=*.md --exclude=Makefile . ~/Downloads/aaa
.PHONY: sync