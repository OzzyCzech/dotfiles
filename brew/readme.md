# Brew

## Backup

```shell
brew leaves --installed-on-request >brew/brew-list.txt
brew list --cask >brew/brew-list-cask.txt
brew tap >brew/brew-tap.txt
```

## Install

```shell
xargs -n1 -t brew tap < brew-tap.txt
xargs -n1 -t brew install < brew-list.txt
xargs -n1 -t brew install --cask < brew-list-cask.txt
```