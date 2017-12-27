# Mariadb

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

Setup to autostart after login (Require [Brew services](./brew-services.md))

```
sudo brew services start mariadb
```

Change rights

```
sudo chown -R _mysql /usr/local/var/mysql
```

## Start & Restart

```
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

## Configure

First setup new password for root

```
mysqladmin -u root password
```