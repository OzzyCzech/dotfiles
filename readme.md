# OzzyCzech's dotfiles for macOS

This is a collection of my personal **dotfiles** for configuring macOS.

## Before you start

You need to install [Homebrew](https://brew.sh/) first:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

then some basic tools:

```shell
brew install git zsh zsh-completions antidote zed
```

- [Zsh](https://www.zsh.org/) - shell designed for interactive use
- [Zsh Completions](https://github.com/zsh-users/zsh-completions) - additional completion definitions for Zsh
- [Oh My Zsh](https://ohmyz.sh/) - framework for managing your Zsh configuration
- [Antidote](https://getantidote.github.io) - fast zsh plugin manager
- [Git](https://git-scm.com/) - version control system
- [Zed](https://zed.dev/) - code editor for the 21st century

and set zsh as your default shell:

```shell
chsh -s /bin/zsh
```

## Dotfiles installation

```shell
git clone git@github.com:OzzyCzech/dotfiles.git ~/.dotfiles && cd $_ && make
```

## Docs

### Setup defaults

There is a bunch of setup scripts in the `setup` directory. You can run them one by one:

```shell
source ./setup/defaults.zsh
```

#### Setup lock screen message 

The lock screen message can help you to get your lost device back.
Can be set by running the following command:

```shell
set-lock-message " Roman Ožana • +420 605 783 455 • roman@ozana.cz"
set-screen-capture ~/Downloads
```

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