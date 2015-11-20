# How to install NGINX, PHP-FPM (5.6+), Mongodb, Redis, Nodejs, Mysql, Git

## Preparation

Install [Homebrew](http://brew.sh/)

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew doctor

Read first [El Capitan & Homebrew](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/El_Capitan_and_Homebrew.md) and follow instruction.

And install [Cask](http://caskroom.io/)

    brew install caskroom/cask/brew-cask && brew cask update


Then install [Atom editor](https://atom.io/) and chose from Atom menu *Install Shell Commands*

    brew cask install atom

## Docker

First install [VirtualBox](https://www.virtualbox.org/)
    
    brew cask install virtualbox

Then install docker and docker-machine:

    brew install docker-machine
    brew install docker-compose
    brew install docker
    
Create your docker

    docker-machine create --driver virtualbox dev
    docker-machine ls # show current machines
    eval "$(docker-machine env dev)"
    docker-machine env dev

-  https://docs.docker.com/machine/get-started/ - Starting with Docker machine
-  https://hub.docker.com/

## NGINX

### Install

    brew install nginx

### Running

Follow command will autostart nginx after login

    ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents

You can start nginx manually and check if running in browser

    sudo nginx            # start
    sudo nginx -s stop    # stop
    sudo nginx -s reload  # restart

Check if running `open http://localhost:8080` or `open http://localhost:80`

### Configuration

nginx configuration files can be found here `atom /usr/local/etc/nginx`

Here is my basic `nginx.conf` file (do not forgot change root path):

    #user  nobody;
    worker_processes  1;

    #error_log  logs/error.log;
    #error_log  logs/error.log  notice;
    #error_log  logs/error.log  info;

    events {
        worker_connections  1024;
    }


    http {
        include       mime.types;
        include       sites-enabled/*; # load virtuals config
        sendfile        on;
        keepalive_timeout  65;

        # gzip  on;
        # gzip_disable "MSIE [1-6]\.(?!.*SV1)";

        server {
            listen       80;
            server_name  localhost;

            location / {
                root  /Users/roman/Sites;
                try_files  $uri  $uri/  /index.php?$args ;
                index  index.php;
            }

            # configure *.PHP requests

            location ~ \.php$ {
                root  /Users/roman/Sites;
                try_files  $uri  $uri/  /index.php?$args ;
                index  index.html index.htm index.php;
                fastcgi_param PATH_INFO $fastcgi_path_info;
                fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_intercept_errors on;
                include fastcgi_params;
            }
        }
    }

### Setup virtuals

First prepare follow dirs

    mkdir /usr/local/etc/nginx/sites-available
    mkdir /usr/local/etc/nginx/sites-enabled

Create first dev configuration:

    atom /usr/local/etc/nginx/sites-available/omdesign.dev

Here is my example configuration:

    server {
      listen                *:80;
      server_name           omdesign.dev;
      #access_log           /Users/roman/Work/omdesign.cz/log/omdesign.dev.access.log;
      #error_log            /Users/roman/Work/omdesign.cz/log/omdesign.dev.error.log;

      location / {
        root  /Users/roman/Work/omdesign.cz;
        try_files  $uri  $uri/  /index.php?$args;
        index index.php;
      }

      location ~ \.php$ {
        root  /Users/roman/Work/omdesign.cz;
        try_files  $uri  $uri/  /index.php?$args;
        index  index.html index.htm index.php;

        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;


        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_intercept_errors on;
        include fastcgi_params;
      }

    }

Create symlink to sites-enabled:

    sudo ln -s /usr/local/etc/nginx/sites-available/omdesign.dev /usr/local/etc/nginx/sites-enabled/omdesign.dev

Update your `atom /etc/hosts` file with follow line:

    127.0.0.1   omdesign.dev

Restart nginx (`sudo nginx -s reload`) and check if working (`open http://omdesign.dev`)

## PHP-fpm

### Install

Start with taping formulas repositories:

    brew tap homebrew/dupes
    brew tap homebrew/versions
    brew tap homebrew/homebrew-php

Remove all PHP dependencies (it's only safe way how to compile PHP successfully)

    brew remove libtool freetype gettext icu4c jpeg libpng unixodbc zlib

Then install PHP

    brew install -v --with-fpm --with-mysql --disable-opcache php56

Launch after login

    ln -sfv /usr/local/opt/php56/*.plist ~/Library/LaunchAgents

### Install PHP extensions

    brew install php56-http
    brew install php56-mcrypt
    brew install php56-memcache
    brew install php56-memcached
    brew install php56-mongo
    brew install php56-opcache
    brew install php56-propro
    brew install php56-raphf
    brew install php56-tidy
    brew install php56-xdebug
    # ...

add launch agent for memcached

    ln -sfv /usr/local/opt/memcached/*.plist ~/Library/LaunchAgents

or get others

    brew search php56

What about APC? See [stackoverflow](http://stackoverflow.com/questions/9611676/is-apc-compatible-with-php-5-4-or-php-5-5) - APC have some problems but you can install emulated APC

    brew install php56-apcu # APC

### Replace OS X PHP

change `~/.bash_profile` add follow line:

    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

Restart Terminal and check if working `php -v` or `php-fpm -v`

### Configuration and php.ini

You can found basic php-fpm config file here `atom /usr/local/etc/php/5.6/php-fpm.conf`. Check especially `listen = 127.0.0.1:9000` everything else can be leave as is.

PHP config files can be found here `atom /usr/local/etc/php/5.6/conf.d/`. You can change `php.ini` but its more more easly keept change is spearate file:

    atom  /usr/local/etc/php/5.6/conf.d/zzzzzzzzzzzzzzzzzzzzzzzz.ini

See my configuration:

    short_open_tag = On
    display_errors = On
    display_startup_errors = On
    upload_max_filesize = 1024M
    post_max_size = 1024M
    date.timezone = "Europe/Prague"
    error_reporting = E_ALL
    memory_limit = 256M

    log_errors=On
    error_log=/tmp/php-error.log

    mysql.default_socket=/tmp/mysql.sock
    pdo_mysql.default_socket=/tmp/mysql.sock

    [opcache]
    opcache.revalidate_freq=1

    [xdebug]
    xdebug.remote_enable=1
    xdebug.remote_connect_back=On
    ;xdebug.remote_host=127.0.0.1
    ;xdebug.remote_port=9001
    xdebug.remote_autostart=1
    xdebug.idekey=PHPSTORM
    xhprof.output_dir="/var/tmp/xhprof"

    xdebug.profiler_enable = 0;
    xdebug.profiler_output_name=cachegrind.out.%H.%t
    xdebug.profiler_enable_trigger = 1;
    xdebug.profiler_output_dir = /Users/roman/.Trash


## mongodb

    brew install mongodb
    brew link mongodb

Setup to autostart after login

    ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents

### Start & stop

    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist

## mysql

    brew install mysql

Run the commands brew suggested

    unset TMPDIR
    mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
    
Start mysql use commands

    mysql.server start

Setup to autostart after login

    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents

Change rights

    sudo chown -R _mysql /usr/local/var/mysql

### Start & restart

    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

### Confugure

First setup new password for root

    mysqladmin -u root password

## nodejs & npm

    brew install nodejs
    nodejs --version
    npm completion > /usr/local/etc/bash_completion.d/npm # bash code completation

Upgrade npm first

    npm install -g npm
    
then install modules

    npm install -g bower 
    npm install -g phantomjs
    npm install -g less
    npm install -g gulp
    npm install -g grunt-cli
    npm install -g coffee-script
    npm install -g babel
    npm install -g webdriver
    npm install -g chromedriver
    npm install -g npm-check-updates
    npm install -g phantomjs
    npm install -g protractor

## bash (need to be upgrade for new Git)

    brew install bash

Open terminal ⌘+, setup path to new bash `/usr/local/bin/bash`

    sudo atom /etc/shells

add this line at the end of the list:

    /usr/local/bin/bash

and

    chsh -s /usr/local/bin/bash YOUR_USER_NAME

after that relaunch Terminal and check bash version

    echo $BASH_VERSION

## Redis

	brew install redis
	ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents

## Git

    brew install git
    brew unlink git && brew link git
    brew info git
    brew install git-extra
    brew install git bash-completion

And update your `~/.bash_profile` to add autocomplete and prompt:

    #############################################################################
    # My current prompt
    #############################################################################

    # \d – Current date
    # \t – Current time
    # \h – Host name
    # \# – Command number
    # \u – User name
    # \W – Current working directory (ie: Desktop/)
    # \w – Current working directory, full path (ie: /Users/Admin/Desktop)
    # export PS1="\u@\h\w: "
    export PS1="\w: "

    #############################################################################
    # git autocomplet and bash prompt
    #############################################################################

    source `brew --prefix git`/etc/bash_completion.d/git-completion.bash
    source `brew --prefix git`/etc/bash_completion.d/git-prompt.sh

    # configure yout git and prompt

    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="git verbose legacy"
    export PSORIG="$PS1" # or remove if you don't have My custom prompt

    PS1=$PSORIG'$(__git_ps1 "\[\033[01;31m\]%s \[\033[00m\]")'

Restart terminal (need to be relaunch with ⌘+Q). Get more info from my [.bash_profile](https://github.com/OzzyCzech/dotfiles/blob/master/.bash_profile) file.

## Others

Install GNU core utilities (those that come with OS X are outdated):

    brew install coreutils

Don't forget add `/usr/local/Cellar/coreutils/8.21/libexec/gnubin` to $PATH

Find, Locate etc. for mac

    brew install findutils

Rename command:

    brew install rename

Tree command for mac:

    brew install tree

Install wget:

    brew install wget --enable-iri

See [.brew](https://github.com/OzzyCzech/dotfiles/tree/master/brew) for more information

# Software

Execute follow commands:

    brew cask install disk-inventory-x
    brew cask install rowanj-gitx
    brew cask install rowanj-gitx
    brew cask install sourcetree
    brew cask install viscosity
    brew cask install vlc
    brew cask install virtualbox
    brew cask install twitter
    brew cask install tweetdeck
    brew cask install robomongo
    brew cask install google-chrome
    brew cask install firefox
    brew cask install macdown
    brew cask install the-unarchiver
    brew cask install slack
    brew cask install poedit
    
## Others

- **Window Magnet**: missing mac window organizer ([buy here](https://itunes.apple.com/cz/app/window-magnet/id441258766?mt=12
))
- **MiroVideo Converter**: A beautiful, simple way to convert almost any video to MP4, WebM (vp8), Ogg Theora, or for Android, iPhone, and iPad. Batch conversion, custom sizing, and more!
http://www.mirovideoconverter.com/
- **HandBrake** is a tool for converting video from nearly any format to a selection of modern, widely supported codecs. https://handbrake.fr/

# Troubleshooting

### Remove PHP and all dependencies

Follow procedure fix a most of problems like: Segmentation fault, compile errors or dependencies problem.

     brew update
     brew rm $(brew deps php56)
     brew cleanup
     brew install -v --with-fpm --with-mysql --disable-opcache php56
     # etc.

### Change local Forumlas

All local formulas can be found in paths:

    /usr/local/Library/Formula
    /usr/local/Library/Taps/homebrew/

It's a git repo, you can checkout any older source from github.

### Dubious ownership

If you get error like: `Dubious ownership on file...` need to change plist rights:

    sudo chown root ~/Library/LaunchAgents/*.plist
    sudo chmod 644 ~/Library/LaunchAgents/*.plist
