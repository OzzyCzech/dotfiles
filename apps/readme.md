# Apps

Homebrew packages and Mac App Store apps backup/restore.

## Backup everything

```shell
brew leaves --installed-on-request > apps/brew-list.txt
brew list --cask > apps/brew-list-cask.txt
brew tap > apps/brew-tap.txt
mas list > apps/mas-list.txt
```

## Install everything from backup

```shell
xargs -n1 -t brew tap < apps/brew-tap.txt
xargs -n1 -t brew install < apps/brew-list.txt
xargs -n1 -t brew install --cask < apps/brew-list-cask.txt
awk '{print $1}' apps/mas-list.txt | xargs -n1 -t mas install
```

## Install MongoDB tools and shell only

```shell
brew tap mongodb/brew
brew install mongodb/brew/mongodb-community-shell
brew install mongodb/brew/mongodb-database-tools
brew install mongosh
```

More info: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/
