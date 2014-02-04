# Install NGINX, PHP-FPM (5.5.6), Mongo and MySql

## Preparation

Download [Sublime editor](http://www.sublimetext.com/) and create link `subl`:

    sudo ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /bin/subl

Install [Homebrew](http://brew.sh/)

    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"

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

nginx configuration files can be found here `subl /usr/local/etc/nginx`
    
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
        include       sites-enabled/*.dev; # load virtuals config
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

    subl /usr/local/etc/nginx/sites-available/omdesign.dev
   
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

    sudo ln -s /usr/local/etc/nginx/sites-available/omdesign.dev /usr/local/etc/nginx/sites-nabled/omdesign.dev
    
Update your `subl /etc/hosts` file with follow line:

    127.0.0.1   omdesign.dev

Restart nginx (`sudo nginx -s reload`) and check if working (`open http://omdesign.dev`)

## PHP-fpm

### Install

    brew tap homebrew/dupes
    brew tap josegonzalez/homebrew-php
    brew install --without-apache --with-fpm --with-mysql php55

Launch after login

    ln -sfv /usr/local/opt/php55/*.plist ~/Library/LaunchAgents
    
### Install PHP extensions

    brew install php55-mongo
    brew install php55-xdebug
    brew install php55-memcache
    brew install php55-memcached
    brew install php55-opcache
    brew install php55-xhprof

add launch agent for memcached

    ln -sfv /usr/local/opt/memcached/*.plist ~/Library/LaunchAgents    
    
or get others
 
    brew search php55
    
What about APC? See [stackoverflow](http://stackoverflow.com/questions/9611676/is-apc-compatible-with-php-5-4-or-php-5-5) - APC have some problems but you can install emulated APC

    brew install php55-apcu # APC

### Replace OS X PHP

change `~/.bash_profile` add follow line:

    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    
Restart Terminal and check if working `php -v` or `php-fpm -v`

### Configuration and php.ini

You can found basic php-fpm config file here `subl /usr/local/etc/php/5.5/php-fpm.conf`. Check especially `listen = 127.0.0.1:9000` everything else can be leave as is.

PHP config files can be found here `subl /usr/local/etc/php/5.5/conf.d/`. You can change `php.ini` but its more more easly keept change is spearate file:

    subl /usr/local/etc/php/5.5/conf.d/zzzzzzzzzzzz.ini

See my configuration:

    short_open_tag = On
    display_errors = On
    display_startup_errors = On
    upload_max_filesize = 256M
    date.timezone = "Europe/Prague"
    error_reporting = E_ALL
    xdebug.idekey=PHPSTORM
    xhprof.output_dir="/var/tmp/xhprof"

## mongo

    brew install mongodb
    brew link mongod

Setup to autostart after login

    ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents

### Start & restart

    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
    
## mysql

    brew install mysql
    
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

## bash (need to be upgrade for new Git)

    brew install bash

Open terminal cmd+, setup path to new bash `/usr/local/bin/bash`

    sudo subl /etc/shells

add this line at the end of the list:

    /usr/local/bin/bash

and 

    chsh -s /usr/local/bin/bash YOUR_USER_NAME

after that relaunch Terminal and check bash version

    echo $BASH_VERSION

## git

    brew install git
    brew unlink git && brew link git
    brew info git

And update your `~/.bash_profile` to add autocomplete and prompt
    
    
    #############################################################################
    # My current prompt
    #############################################################################
    
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

Restart terminal (need to be quit and relaunch cmd+q)

## Others

    brew install npm

Install GNU core utilities (those that come with OS X are outdated)

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

See [.brew](https://github.com/addyosmani/dotfiles/blob/master/.brew) for more information
