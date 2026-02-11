# OzzyCzech's dotfiles

Personal macOS config. Zsh, Antidote, Zed, and helpers.

## Quick start

```shell
git clone git@github.com:OzzyCzech/dotfiles.git ~/.dotfiles && cd $_ && make
```

## Prerequisites

Install [Homebrew](https://brew.sh/):

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install tools:

```shell
brew install git zsh zsh-completions antidote zed
```

- [Zsh](https://www.zsh.org/) — interactive shell
- [Zsh Completions](https://github.com/zsh-users/zsh-completions) — extra completions
- [Antidote](https://getantidote.github.io) — fast Zsh plugin manager
- [Git](https://git-scm.com/) — version control
- [Zed](https://zed.dev/) — code editor

Set Zsh as default shell:

```shell
chsh -s /bin/zsh
```

## Setup scripts

Scripts live in `setup/`. Run individually, e.g.:

```shell
source ./setup/defaults.zsh
```

### Lock screen message

Helps recover a lost device.

```shell
set-lock-message " Roman Ožana • +420 605 783 455 • roman@ozana.cz"
set-screen-capture ~/Downloads
```

### Backup SSH keys

```shell
zip -r ~/Downloads/ssh.zip ~/.ssh
```

### Backup app settings with [Mackup](https://github.com/lra/mackup)

```shell
brew install mackup
mackup backup
```
