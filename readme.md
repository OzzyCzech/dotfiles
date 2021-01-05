# OzzyCzech's dotfiles for macOS

## Install/update dotfiles

```
git clone https://github.com/OzzyCzech/dotfiles.git && cd dotfiles && make sync && make install
```

## Add private config

All private config can be save in `.extra` which you do not commit to this repo and just keep in your `~/`

```shell
touch ~/.extra && code ~/.extra
```

```shell
brew install zsh zsh-completions
```

To set zsh as your default shell, execute the following for **macOS Big Sur**

```shell
chsh -s /bin/zsh
```

Download my <a href="https://raw.githubusercontent.com/OzzyCzech/dotfiles/master/OzzyCzech.terminal" download="OzzyCzech.terminal">Terminal.app settings</a>.

## Install

* [brew-services](https://github.com/OzzyCzech/dotfiles/blob/master/install/brew-services.md)
* [brew-troubleshooting](https://github.com/OzzyCzech/dotfiles/blob/master/install/brew-troubleshooting.md)
* [git](https://github.com/OzzyCzech/dotfiles/blob/master/install/git.md)
* [mariadb](https://github.com/OzzyCzech/dotfiles/blob/master/install/mariadb.md)
* [mongodb](https://github.com/OzzyCzech/dotfiles/blob/master/install/mongodb.md)
* [nginx](https://github.com/OzzyCzech/dotfiles/blob/master/install/nginx.md)
* [nodejs](https://github.com/OzzyCzech/dotfiles/blob/master/install/nodejs.md)
* [php](https://github.com/OzzyCzech/dotfiles/blob/master/install/php.md)
* [redis](https://github.com/OzzyCzech/dotfiles/blob/master/install/redis.md)

## Credits - for more than simple inspiration

- https://github.com/addyosmani/dotfiles/
- https://github.com/paulirish/dotfiles/
- https://github.com/mathiasbynens/dotfiles/

