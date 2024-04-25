# OzzyCzech's dotfiles for macOS

This is a collection of my personal dotfiles for configuring macOS.

## Install [brew](https://brew.sh)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```shell
brew install git zsh zsh-completions zed
```

To set `zsh` as your default shell with `chsh` command:

```shell
chsh -s /bin/zsh
```

## Install [Oh My Zsh](https://ohmyz.sh/)

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Clone this repo

First, you need to clone this repo and run the `make sync` command:

```shell
git clone git@github.com:OzzyCzech/dotfiles.git .dotfiles && cd $_ && make sync
```

All private config can be saved in `.extra` which you do not commit to this repo and just keep in your `~/`

```shell
touch ~/.extra && zed ~/.extra
```

### Setup lock screen message

The lock screen message can help you to get your lost device back.
Can be set by running the following command:

```shell
./defaults/ScreenMessage.sh " Roman Ožana • +420 605 783 455 • roman@ozana.cz"
```

## Backup your settings

### Backup `.ssh` keys

Do not forget to backup your `.ssh` keys, you can use the following command:

```shell
zip -r ~/Downloads/ssh.zip ~/.ssh
```

### Backup application settings with [Mackup](https://github.com/lra/mackup)

```shell
brew install mackup
mackup backup
```

## Thanks for inspiration

- https://github.com/addyosmani/dotfiles/
- https://github.com/paulirish/dotfiles/
- https://github.com/mathiasbynens/dotfiles/
