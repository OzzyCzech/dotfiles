# OzzyCzech dotfiles for macOS

## Install

Install [Homebrew](http://brew.sh/) package manager:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
```

And install [Cask](http://caskroom.io/)

```
brew tap caskroom/cask
brew cask update
```

Install [Visual Studio Code](https://code.visualstudio.com/) for editing...

```
brew cask install visual-studio-code
```

## Install/update dotfiles

    git clone https://github.com/OzzyCzech/dotfiles.git && cd dotfiles && make sync

To update later on, just run the sync again...

## Add private config

All private config can be save in `.extra` which you do not commit to this repo and just keep in your `~/`

## Others

- [Install NGINX](https://github.com/OzzyCzech/dotfiles/blob/master/nginx.md)
- [Install PHP-fpm](https://github.com/OzzyCzech/dotfiles/blob/master/php.md)

## Credits - for more than simple inspiration

- https://github.com/addyosmani/dotfiles/
- https://github.com/paulirish/dotfiles/
- https://github.com/mathiasbynens/dotfiles/
