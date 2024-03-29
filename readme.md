# OzzyCzech's dotfiles for macOS

## Install [brew](https://brew.sh)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```shell
brew install git zsh zsh-completions rclone zed
```

To set `zsh` as your default shell:

```shell
chsh -s /bin/zsh
```

## Install [Oh My Zsh](https://ohmyz.sh/)

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Clone dotfiles

```shell
git clone git@github.com:OzzyCzech/dotfiles.git .dotfiles && cd $_ && make sync
```

## Add private config

All private config can be saved in `.extra` which you do not commit to this repo and just keep in your `~/`

```shell
touch ~/.extra && zed ~/.extra
```

## Settings

### Backup your `.ssh` keys

Do not forget to back up your `.ssh` keys:

```shell
zip -r ~/Downloads/ssh.zip ~/.ssh
```

### Backup all your settings with [Mackup](https://github.com/lra/mackup)

```shell
brew install mackup
mackup backup
```

### Set lock screen Message

Lock screen message can be set with:

```sh
./defaults/ScreenMessage.sh " Roman Ožana • +420 605 783 455 • roman@ozana.cz"
```

## Thanks for inspiration

- https://github.com/addyosmani/dotfiles/
- https://github.com/paulirish/dotfiles/
- https://github.com/mathiasbynens/dotfiles/
