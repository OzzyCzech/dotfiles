# How to install NGINX, PHP-FPM, Mongodb, Redis, Nodejs, Mariadb, Git

## Preparation

Install [Homebrew](http://brew.sh/) package manager:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
```
Read first [El Capitan & Homebrew](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/El_Capitan_and_Homebrew.md) and follow instruction.

And install [Cask](http://caskroom.io/)

```
brew install caskroom/cask/brew-cask
brew cask update
```

Then install [Atom editor](https://atom.io/) and chose from Atom menu *Install Shell Commands*

```
brew cask install atom
```

Install [brew services](https://github.com/Homebrew/homebrew-services)

```
brew tap homebrew/services
```

## NGINX

```
brew install nginx
```

```
sudo brew services start nginx
```

You can start nginx manually and check if running in browser

```
sudo brew services reload nginx
sudo brew services start nginx
sudo brew services stop nginx
```

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

```
atom /usr/local/etc/nginx/sites-available/omdesign.dev
```

Here is an example configuration:

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

```
sudo ln -s /usr/local/etc/nginx/sites-available/omdesign.dev /usr/local/etc/nginx/sites-enabled/omdesign.dev
```

Update your `atom /etc/hosts` file with follow line:

```
127.0.0.1   omdesign.dev
```

Restart nginx (`sudo brew service reload nginx`) and check if working (`open http://omdesign.dev`)

## PHP-fpm

### Install

Start with taping formulas repositories:

```
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
```

Remove all PHP dependencies (it's only safe way how to compile PHP successfully)

```
brew remove libtool freetype gettext icu4c jpeg libpng unixodbc zlib
```

Then install PHP

```
brew install -v php70
```

Launch after login

```
brew services start homebrew/php/php70
```

### Install PHP extensions

```
brew install php70-apcu
brew install php70-igbinary
brew install php70-intl
brew install php70-mcrypt
brew install php70-memcache
brew install php70-mongo
# brew install php70-redis
brew install php70-tidy
brew install php70-xdebug
# ...
```

```
brew services start homebrew/php/php70
```

or get others

```
brew search php7
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

```
brew install mongodb
brew link mongodb
```

Setup to autostart after login

```
sudo brew services start mongo
sudo brew services reload mongo
```

## Mariadb

```
brew install mariadb
```

Run the commands brew suggested and `mysql_install_db`

```
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
```

To start mysql use command:

```
mysql.server start
```

Setup to autostart after login

```
sudo brew services start mariadb
```

Change rights

```
sudo chown -R _mysql /usr/local/var/mysql
```

### Start & Restart

```
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

### Configure

First setup new password for root

```
mysqladmin -u root password
```

## nodejs & npm

```
brew install nodejs
nodejs --version
npm completion > /usr/local/etc/bash_completion.d/npm # bash code completation
```

Upgrade npm first

```
npm install -g npm
```

then install modules

```
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

```
brew install bash
```

Open terminal ⌘+, setup path to new bash `/usr/local/bin/bash`

```
sudo atom /etc/shells
```

add this line at the end of the list:

```
/usr/local/bin/bash
```

and

```
chsh -s /usr/local/bin/bash YOUR_USER_NAME
```

after that relaunch Terminal and check bash version

```
echo $BASH_VERSION
```

## Redis

```
brew install redis
sudo brew services start redis
```

## Git

```
brew install git
brew unlink git && brew link git
brew info git
brew install git-extra
brew install git bash-completion
```

And update your `~/.bash_prompt` to add autocomplete and prompt:

```
#############################################################################
# current prompt
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
source /usr/local/etc/bash_completion.d/npm

# configure git and prompt

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="git verbose legacy"
export PSORIG="$PS1" # pokud chcete zachovat puvodni PS1

PS1=$PSORIG'$(__git_ps1 "\[\033[01;31m\]%s \[\033[00m\]")'

#############################################################################
# Change Terminal tab name to dir basename
#############################################################################

PROMPT_COMMAND='echo -n -e "\033]0;${PWD##*/}\007"'
```

Restart terminal (need to be relaunch with ⌘+Q).
Get more info from my [.bash_profile](https://github.com/OzzyCzech/dotfiles/blob/master/.bash_profile) and [.bash_prompt](https://github.com/OzzyCzech/dotfiles/blob/master/.bash_prompt) files.

## Others

Install GNU core utilities (those that come with OS X are outdated):

```
brew install coreutils
```

Don't forget add `/usr/local/Cellar/coreutils/8.21/libexec/gnubin` to $PATH

Find, locate, tree, findutils etc. for mac

```
brew install rename
brew install findutils
brew install tree
brew install wget --enable-iri
```

See [.brew](https://github.com/OzzyCzech/dotfiles/tree/master/brew) for more information

# Software

Execute follow commands:

```

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

- **[Window Magnet](https://itunes.apple.com/cz/app/window-magnet/id441258766?mt=12)**: missing mac window organizer
- **[MiroVideo Converter](http://www.mirovideoconverter.com/)**: A beautiful, simple way to convert almost any video to MP4, WebM (vp8), Ogg Theora, or for Android, iPhone, and iPad. Batch conversion, custom sizing, and more!

# Troubleshooting

### Remove PHP and all dependencies

Follow procedure fix a most of problems like: Segmentation fault, compile errors or dependencies problem.
```
brew update
brew rm $(brew deps php70)
brew cleanup
brew install -v php70
# etc.
```

### Change local Formulas

All local formulas can be found in paths:

```
/usr/local/Library/Formula
/usr/local/Library/Taps/homebrew/
```

It's a git repo, you can checkout any older source from github.

### Dubious Ownership

If you get error like: `Dubious ownership on file...` need to change plist rights:

```
sudo chown root ~/Library/LaunchAgents/*.plist
sudo chmod 644 ~/Library/LaunchAgents/*.plist
```

### System Integrity Protection issue

Fix [SIP protection](https://support.apple.com/en-us/HT204899) on El Capitan:

If you had created the `/usr/local` directory already, then run this command in terminal:

```
sudo chown $(whoami):admin /usr/local && sudo chown -R $(whoami):admin /usr/local
```

If you are doing a fresh install or cannot create /usr/local directory anymore, then follow these steps:

1. Reboot and hold on boot Cmd+R
2. In recovery run in Terminal command run `csrutil disable`
3. Reboot to El Capitan and run follow command in Terminal

```
sudo mkdir /usr/local && sudo chflags norestricted /usr/local && sudo chown $(whoami):admin /usr/local && sudo chown -R $(whoami):admin /usr/local
```

Then reboot to again recovery tool and return `csrutil enable`
