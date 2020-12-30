# Mariadb

```shell
brew install mariadb
```

Run the commands brew suggested and `mysql_install_db`

```shell
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
```

To start mysql use command:

```shell
mysql.server start
```

Setup to autostart after login (require [Brew services](./brew-services.md))

```
sudo brew services start mariadb
```

Change rights

```shell
sudo chown -R _mysql /usr/local/var/mysql
```

## Start & Restart

```shell
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

## Configure

First setup new password for root

```shell
mysqladmin -u root password
```