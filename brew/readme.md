# Brew

Brew is a [package manager](https://brew.sh) for macOS. 

## Backup everything

```shell
brew leaves --installed-on-request >brew/brew-list.txt
brew list --cask >brew/brew-list-cask.txt
brew tap >brew/brew-tap.txt
```

## Install everything from backup

```shell
xargs -n1 -t brew tap < brew-tap.txt
xargs -n1 -t brew install < brew-list.txt
xargs -n1 -t brew install --cask < brew-list-cask.txt
```

## Install MongoDB tools and shell only

```shell
brew tap mongodb/brew
brew install mongodb/brew/mongodb-community-shell
brew install mongodb/brew/mongodb-database-tools
brew install mongosh
```

More info: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/