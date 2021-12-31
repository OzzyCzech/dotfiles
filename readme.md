# OzzyCzech's dotfiles for macOS

## Install/update dotfiles

```shell
git clone https://github.com/OzzyCzech/dotfiles.git dotfiles && cd $_ && make sync
```

## Add private config

All private config can be save in `.extra` which you do not commit to this repo and just keep in your `~/`

```shell
touch ~/.extra && code ~/.extra
```

```shell
brew install zsh zsh-completions
```

To set `zsh` as your default shell, execute the following for **macOS Monterey**

```shell
chsh -s /bin/zsh
```

## Terminal setup

Set in Terminal configuration `⌘+,` in Advanced > Declarative terminal as `ansi` to enable numpad keyboard.
Download my [Terminal.app color settings](https://raw.githubusercontent.com/OzzyCzech/dotfiles/install/main/OzzyCzech.terminal).

## Install Docker

```shell
open https://desktop.docker.com/mac/main/amd64/Docker.dmg # Intel
open https://desktop.docker.com/mac/main/arm64/Docker.dmg # Apple Silicon
```


## Thanks for inspiration

- https://github.com/addyosmani/dotfiles/
- https://github.com/paulirish/dotfiles/
- https://github.com/mathiasbynens/dotfiles/