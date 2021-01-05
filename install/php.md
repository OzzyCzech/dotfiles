# PHP-fpm

Install [brew services](https://github.com/Homebrew/homebrew-services)

```
brew tap homebrew/services
```

Start with taping formulas repositories:

```
brew tap homebrew/homebrew-php
brew options php72
```

Remove all PHP dependencies (it's only safe way how to compile PHP successfully)

```shell
brew remove libtool freetype gettext icu4c jpeg libpng unixodbc zlib
```

Then install PHP

```shell
brew install -v php72
```

Launch after login

```
brew services start homebrew/php/php72
```

### Install PHP extensions

```
brew install php72-apcu
brew install php72-intl
brew install php72-memcached
brew install php72-opcache
brew install php72-tidy
brew install php72-xdebug
# ...
```

```
brew services start homebrew/php/php72
```

or get others

```
brew search php7
```

## Replace OS X PHP

change `~/.bash_profile` add follow line:

```
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
```

Restart Terminal and check if working `php -v` or `php-fpm -v`

## Configuration and php.ini

You can found basic php-fpm config file here `code /usr/local/etc/php/7.2/php-fpm.conf`. Check especially `listen = 127.0.0.1:9000` everything else can be leave as is.

PHP config files can be found here `code /usr/local/etc/php/7.2/conf.d/`. You can change `php.ini` but its more more easly keept change is spearate file:

```
code /usr/local/etc/php/7.0/conf.d/zzzzzzzzzzzzzzzzzzzzzzzz.ini
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


## Remove PHP and all dependencies

Follow procedure fix a most of problems like: Segmentation fault, compile errors or dependencies problem.

```
brew update
brew rm $(brew deps php71)
brew cleanup
brew install -v php72
# etc.
```