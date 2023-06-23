# OzzyCzech's dotfiles for macOS

## Install [brew](https://brew.sh)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Install prerequisites

```shell
brew install git zsh zsh-completions rclone zed
```

To set `zsh` as your default shell:

```shell
chsh -s /bin/zsh
```

## Install [Oh My Zsh](https://ohmyz.sh/):

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Download/clonse dotfiles

```shell
git clone git@github.com:OzzyCzech/dotfiles.git dotfiles && cd $_ && make sync
```

## Add private config

All private config can be saved in `.extra` which you do not commit to this repo and just keep in your `~/`

```shell
touch ~/.extra && zed ~/.extra
```

## Terminal setup

Set in Terminal configuration `⌘+,` in Advanced > Declarative terminal as `ansi` to enable numpad keyboard.

Download my [Terminal.app color settings](https://raw.githubusercontent.com/OzzyCzech/dotfiles/install/main/OzzyCzech.terminal).

## Thanks for inspiration

- https://github.com/addyosmani/dotfiles/
- https://github.com/paulirish/dotfiles/
- https://github.com/mathiasbynens/dotfiles/
