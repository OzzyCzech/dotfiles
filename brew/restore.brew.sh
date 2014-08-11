#!/bin/bash
#
# # # DO NOT RUN AS SUDO !!! # # #
#
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# tap
brew tap homebrew/dupes
brew tap homebrew/php
brew tap homebrew/versions

# upgrade brew
brew update && brew upgrade

# install all items
brew install ack ''
brew install ant ''
brew install autoconf ''
brew install bash ''
brew install c-ares ''
brew install coreutils ''
brew install curl ''
brew install exiftool ''
brew install freetype ''
brew install gettext ''
brew install git ''
brew install git-extras ''
brew install graphviz ''
brew install imagemagick ''
brew install jpeg ''
brew install libevent ''
brew install libiconv ''
brew install libmemcached ''
brew install libpng ''
brew install libtool ''
brew install mcrypt ''
brew install memcached ''
brew install mhash ''
brew install mongodb ''
brew install mysql ''
brew install nginx ''
brew install node ''
brew install openssl ''
brew install pcre ''
brew install php55 '  --without-apache  --with-fpm'
brew install php55-apcu ''
brew install php55-http ''
brew install php55-mcrypt ''
brew install php55-memcache ''
brew install php55-memcached ''
brew install php55-mongo ''
brew install php55-opcache ''
brew install php55-propro ''
brew install php55-raphf ''
brew install php55-tidy ''
brew install php55-xdebug ''
brew install phpunit ''
brew install pkg-config ''
brew install readline ''
brew install redis ''
brew install rename ''
brew install scons ''
brew install tree ''
brew install unixodbc ''
brew install wget ''
brew install xz ''
brew install zlib ''
brew cleanup
