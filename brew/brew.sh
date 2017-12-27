#!/bin/bash

#############################################################################
# Brew
#############################################################################

if ! command -v brew >/dev/null 2>&1 ; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else    
    echo "\033[0;32m[OK]\033[0m brew already installed"
fi;

#############################################################################
# Tap...
#############################################################################

while read -r tap; do    
    if ! brew tap | grep "caskroom/cask"  &>/dev/null ; then
        echo "\033[0;31m[MISSING]\033[0m $tap..."
        brew tap $tap
    else 
        echo "\033[0;32m[OK]\033[0m $tap already tapped"
    fi;
done < "./tap.txt"

brew doctor
brew update
brew cask update

#############################################################################
# Casks and packages
#############################################################################

while read -r cask; do    
    if ! brew cask ls --versions $cask >/dev/null 2>&1; then
        echo "\033[0;31m[MISSING]\033[0m $cask..."
        brew cask install $cask
    else 
        echo "\033[0;32m[OK]\033[0m $cask already installed"
    fi;
done < "./cask-list.txt"

#############################################################################
# Brew packages
#############################################################################


while read -r package; do    
    if ! brew ls --versions $package >/dev/null 2>&1; then
        echo "\033[0;31m[MISSING]\033[0m $package..."
        brew install $package
    else 
        echo "\033[0;32m[OK]\033[0m $cask already installed"
    fi;
done < "./list.txt"

#############################################################################
# Upgrade already installed
#############################################################################

if [ -x "$(brew outdated)" ]; then
    echo "[INFO] there are some outdated packages"
    brew outdated
    read -p "Continue installing outdated brews [y]? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then    
        brew upgrade
    fi;
fi;

brew cleanup && brew prune