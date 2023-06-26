#!/usr/bin/env bash

xargs -n1 -t brew tap < brew-tap.txt
xargs -n1 -t brew install < brew-list.txt
xargs -n1 -t brew install --cask < brew-list-cask.txt
    