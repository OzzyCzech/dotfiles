#!/usr/bin/env zsh
# One-time seed of zoxide database with frequently used paths.
# Run after a fresh install: zsh setup/zoxide-seed.zsh

paths=(
  ~/.dotfiles
  /Volumes/Work/testomato
  /Volumes/Work/testomato/app
  /Volumes/Work/testomato/web
  /Volumes/Work/ozana.cz
  /Volumes/Work/ozzyczech.cz
  /Volumes/Work/zdrojak.cz
  /Volumes/Work/wiki
)

for p in $paths; do
  [[ -d $p ]] && zoxide add "$p" && echo "added: $p"
done
