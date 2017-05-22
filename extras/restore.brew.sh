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
brew install adns ''
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
brew install gmp ''
brew install gnupg ''
brew install gnupg2 ''
brew install gnutls ''
brew install go ''
brew install gpg-agent ''
brew install httpie ''
brew install hugo ''
brew install icdiff ''
brew install icu4c ''
brew install jpeg ''
brew install libassuan ''
brew install libffi ''
brew install libgcrypt ''
brew install libgpg-error ''
brew install libidn ''
brew install libksba ''
brew install libpng ''
brew install libsass ''
brew install libtasn1 ''
brew install libtiff ''
brew install libtool ''
brew install libunistring ''
brew install libusb ''
brew install libusb-compat ''
brew install libxml2 ''
brew install libyaml ''
brew install nettle ''
brew install node ''
brew install npth ''
brew install openssl ''
brew install p11-kit ''
brew install pcre ''
brew install php71 ''
brew install php71-apcu ''
brew install pinentry ''
brew install pkg-config ''
brew install pth ''
brew install python ''
brew install python3 ''
brew install rclone ''
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
