#!/bin/bash
#
# # # DO NOT RUN AS SUDO !!! # # #
#
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# tap
brew tap caskroom/cask
brew tap homebrew/core
brew tap homebrew/dupes
brew tap homebrew/php
brew tap homebrew/services
brew tap homebrew/versions

# upgrade brew
brew update && brew upgrade

# install all items
brew install ack ''
brew install bash ''
brew install bash-completion ''
brew install coreutils ''
brew install findutils ''
brew install freetype ''
brew install gettext ''
brew install git ''
brew install go ''
brew install hugo ''
brew install icu4c ''
brew install jpeg ''
brew install libidn ''
brew install libpng ''
brew install libsass ''
brew install libxml2 ''
brew install node ''
brew install openssl ''
brew install php70 ''
brew install pkg-config ''
brew install readline ''
brew install rename ''
brew install tree ''
brew install unixodbc ''
brew install wget ''
brew install xz ''
brew cleanup
