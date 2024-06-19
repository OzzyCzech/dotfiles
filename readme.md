# OzzyCzech's dotfiles for macOS

This is a collection of my personal dotfiles for configuring macOS.

## Install [brew](https://brew.sh)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install the following packages:

```shell
brew install git zsh zsh-completions antidote zed
```

- [Zsh](https://www.zsh.org/) - shell designed for interactive use
- [Zsh Completions](https://github.com/zsh-users/zsh-completions) - additional completion definitions for Zsh
- [Oh My Zsh](https://ohmyz.sh/) - framework for managing your Zsh configuration
- [Antidote](https://getantidote.github.io) - fast zsh plugin manager
- [Git](https://git-scm.com/) - version control system
- [Zed](https://zed.dev/) - code editor for the 21st century

To set `zsh` as your default shell with `chsh` command:

```shell
chsh -s /bin/zsh
```

## Install dotfiles

```shell
git clone git@github.com:OzzyCzech/dotfiles.git ~/.dotfiles && cd $_ && make
```

### Setup lock screen message

The lock screen message can help you to get your lost device back.
Can be set by running the following command:

```shell
./defaults/ScreenMessage.sh " Roman Ožana • +420 605 783 455 • roman@ozana.cz"
```

## Backup your settings

### Backup `.ssh` keys

Do not forget to back up your `.ssh` keys, you can use the following command:

```shell
zip -r ~/Downloads/ssh.zip ~/.ssh
```

### Backup application settings with [Mackup](https://github.com/lra/mackup)

```shell
brew install mackup
mackup backup
```