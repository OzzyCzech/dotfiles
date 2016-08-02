# How to install NGINX, PHP-FPM (7), Mongodb, Redis, Nodejs, Mariadb, Git

## Preparation

Install [Homebrew](http://brew.sh/) package manager:

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
```
Read first [El Capitan & Homebrew](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/El_Capitan_and_Homebrew.md) and follow instruction.

And install [Cask](http://caskroom.io/)

```bash
brew install caskroom/cask/brew-cask && brew cask update
```
Then install [Atom editor](https://atom.io/) and chose from Atom menu *Install Shell Commands*
```bash
brew cask install atom
```

## NGINX

### Install

```bash
brew install nginx
```
### Running

Follow command will autostart nginx after login

```bash
ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
```

You can start nginx manually and check if running in browser

    sudo nginx            # start
    sudo nginx -s stop    # stop
    sudo nginx -s reload  # restart

Check if running `open http://localhost:8080` or `open http://localhost:80`

### Configuration

nginx configuration files can be found here `atom /usr/local/etc/nginx`

Here is my basic `nginx.conf` file (do not forgot change root path):
```
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
```

### Setup virtuals

First prepare follow dirs

```
mkdir /usr/local/etc/nginx/sites-available
mkdir /usr/local/etc/nginx/sites-enabled
```

Create first dev configuration:

```bash
atom /usr/local/etc/nginx/sites-available/omdesign.dev
```

Here is my example configuration:

```
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
```

Create symlink to sites-enabled:

```bash
sudo ln -s /usr/local/etc/nginx/sites-available/omdesign.dev /usr/local/etc/nginx/sites-enabled/omdesign.dev
```

Update your `atom /etc/hosts` file with follow line:

```
127.0.0.1   omdesign.dev
```

Restart nginx (`sudo nginx -s reload`) and check if working (`open http://omdesign.dev`)

## PHP-fpm

### Install

Start with taping formulas repositories:

```bash
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
```

Remove all PHP dependencies (it's only safe way how to compile PHP successfully)

```bash
brew remove libtool freetype gettext icu4c jpeg libpng unixodbc zlib
```

Then install PHP

```bash
brew install -v --with-fpm --with-mysql --disable-opcache php56
```

Launch after login

```bash
ln -sfv /usr/local/opt/php56/*.plist ~/Library/LaunchAgents
```

### Install PHP extensions

```bash
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
```

add launch agent for memcached

```
ln -sfv /usr/local/opt/memcached/*.plist ~/Library/LaunchAgents
```

or get others

```
brew search php7
```

What about APC? See [stackoverflow](http://stackoverflow.com/questions/9611676/is-apc-compatible-with-php-5-4-or-php-5-5) - APC have some problems but you can install emulated APC

```
brew install php56-apcu # APC
```

### Replace OS X PHP


change `~/.bash_profile` add follow line:

```
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
```

Restart Terminal and check if working `php -v` or `php-fpm -v`

### Configuration and php.ini

You can found basic php-fpm config file here `atom /usr/local/etc/php/5.6/php-fpm.conf`. Check especially `listen = 127.0.0.1:9000` everything else can be leave as is.

PHP config files can be found here `atom /usr/local/etc/php/5.6/conf.d/`. You can change `php.ini` but its more more easly keept change is spearate file:

```
atom /usr/local/etc/php/5.6/conf.d/zzzzzzzzzzzzzzzzzzzzzzzz.ini
```

See my configuration:

```ini
short_open_tag = On
display_errors = On
display_startup_errors = On
upload_max_filesize = 1024M
post_max_size = 1024M
date.timezone = "Europe/Prague"
error_reporting = E_ALL
memory_limit = 256M
phar.readonly = 0
max_execution_time = 300
always_populate_raw_post_data = -1

log_errors = On
error_log = /tmp/php-error.log

mysql.default_socket = /tmp/mysql.sock
pdo_mysql.default_socket = /tmp/mysql.sock

[opcache]
opcache.revalidate_freq = 0

[xdebug]
xdebug.remote_enable = 1
xdebug.remote_connect_back = On
;xdebug.remote_host=127.0.0.1
;xdebug.remote_port=9001
xdebug.remote_autostart = 1
xdebug.idekey = PHPSTORM

xdebug.profiler_enable = 0;
xdebug.profiler_output_name = cachegrind.out.%H.%t
xdebug.profiler_enable_trigger = 1;
xdebug.profiler_output_dir = /Users/roman/.Trash
```

## mongodb

```bash
brew install mongodb
brew link mongodb
```

Setup to autostart after login

```bash
ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents
```

### Start & Stop

```bash
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
```

## Mariadb

```bash
brew install mariadb
```

Run the commands brew suggested and `mysql_install_db`

```bash
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
```

To start mysql use command:

```bash
mysql.server start
```

Setup to autostart after login

```bash
ln -sfv /usr/local/opt/mariadb/*.plist ~/Library/LaunchAgents
```

Change rights

```bash
sudo chown -R _mysql /usr/local/var/mysql
```

### Start & Restart

```bash
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

### Configure

First setup new password for root

```bash
mysqladmin -u root password
```

## nodejs & npm

```bash
brew install nodejs
nodejs --version
npm completion > /usr/local/etc/bash_completion.d/npm # bash code completation
```

Upgrade npm first

```bash
npm install -g npm
```

then install modules

```bash
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
npm install -g protractor
```

## bash (need to be upgrade for new Git)

```bash
brew install bash
```

Open terminal ⌘+, setup path to new bash `/usr/local/bin/bash`

```bash
sudo atom /etc/shells
```

add this line at the end of the list:

```
/usr/local/bin/bash
```

and

```bash
chsh -s /usr/local/bin/bash YOUR_USER_NAME
```

after that relaunch Terminal and check bash version

```bash
echo $BASH_VERSION
```

## Redis

```bash
brew install redis
ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
```

## Git

```bash
brew install git
brew unlink git && brew link git
brew info git
brew install git-extra
brew install git bash-completion
```

And update your `~/.bash_profile` to add autocomplete and prompt:

```bash
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
```

Restart terminal (need to be relaunch with ⌘+Q). Get more info from my [.bash_profile](https://github.com/OzzyCzech/dotfiles/blob/master/.bash_profile) file.

## Others

Install GNU core utilities (those that come with OS X are outdated):

```bash
brew install coreutils
```

Don't forget add `/usr/local/Cellar/coreutils/8.21/libexec/gnubin` to $PATH

Find, locate, tree, findutils etc. for mac

```bash
brew install rename
brew install findutils
brew install tree
brew install wget --enable-iri
```

See [.brew](https://github.com/OzzyCzech/dotfiles/tree/master/brew) for more information

# Software

Execute follow commands:

```bash

# Editors
brew cask install atom              # Atom editor
brew cask install macdown           # Markdown editor

# Maintenance
brew cask install disk-inventory-x  # analyze disk space
brew cask install the-unarchiver    # Archive tool


# Browsers
brew cask install torbrowser        # Tor browser
brew cask install firefox           # Firefox
brew cask install google-chrome     # Chrome

# dev
brew cask install rowanj-gitx       # visual git tool
brew cask install gitup             # visual git tool
brew cask install virtualbox        # VM
brew cask install viscosity         # VPN client
brew cask install vnc-viewer        # VNC Viewer
brew cask install cyberduck         # FTP Client
brew cask install poedit            # Gettext editor
brew cask install robomongo         # Mongo GUI client
brew cask install rdm               # Redis client
brew cask install cronnix           # Cron GUI

# Drives & Archive & backup
brew cask install burn              # CD, DVD, BR Burner
brew cask install 1password         # 1Password
brew cask install dropbox           # Dropbox
brew cask install google-drive      # Google drive

# Images
brew cask install exifrenamer       # EXIF renamer
brew cask install imageoptim        # Image optimization and EXIF remover

# Chats
brew cask install messenger         # Facebook Messenger
brew cask install skype             # Skype
brew cask install slack             # Slack
brew cask install hipchat           # Hipchat

# Video, fun & social...
brew cask install vlc               # Video player
brew cask install twitter
brew cask install tweetdeck
brew cask install transmission      # torrent client
brew cask install handbrake         # Video converter
```

## Others

- **Window Magnet**: missing mac window organizer ([buy here](https://itunes.apple.com/cz/app/window-magnet/id441258766?mt=12
))
- **MiroVideo Converter**: A beautiful, simple way to convert almost any video to MP4, WebM (vp8), Ogg Theora, or for Android, iPhone, and iPad. Batch conversion, custom sizing, and more!
http://www.mirovideoconverter.com/

# Troubleshooting

### Remove PHP and all dependencies

Follow procedure fix a most of problems like: Segmentation fault, compile errors or dependencies problem.
```bash
brew update
brew rm $(brew deps php56)
brew cleanup
brew install -v --with-fpm --with-mysql --disable-opcache php56
# etc.
```

### Change local Formulas

All local formulas can be found in paths:

```bash
/usr/local/Library/Formula
/usr/local/Library/Taps/homebrew/
```

It's a git repo, you can checkout any older source from github.

### Dubious Ownership

If you get error like: `Dubious ownership on file...` need to change plist rights:

```bash
sudo chown root ~/Library/LaunchAgents/*.plist
sudo chmod 644 ~/Library/LaunchAgents/*.plist
```
