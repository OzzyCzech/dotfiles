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
brew install dirmngr ''
brew install exiftool ''
brew install fcrackzip ''
brew install findutils ''
brew install fontconfig ''
brew install freetype ''
brew install gd ''
brew install gdbm ''
brew install gettext ''
brew install git ''
brew install gnupg2 ''
brew install go ''
brew install gpg-agent ''
brew install hugo ''
brew install icu4c ''
brew install jpeg ''
brew install libassuan ''
brew install libgcrypt ''
brew install libgpg-error ''
brew install libidn ''
brew install libksba ''
brew install libpng ''
brew install libsass ''
brew install libtiff ''
brew install libtool ''
brew install libusb ''
brew install libusb-compat ''
brew install libxml2 ''
brew install libyaml ''
brew install node ''
brew install openssl ''
brew install php71 ''
brew install pinentry ''
brew install pkg-config ''
brew install pth ''
brew install python ''
brew install readline ''
brew install rename ''
brew install ruby ''
brew install sqlite ''
brew install tree ''
brew install unixodbc ''
brew install webp ''
brew install wget ''
brew install xz ''
brew install yarn ''
brew cleanup
