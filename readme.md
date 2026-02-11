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

Scripts live in `setup/` (see `setup/README.md` for layout):

- **apps/** — app-specific defaults (Dock, Finder, Mail, …): run e.g. `zsh setup/apps/finder.zsh`
- **system/** — system & input (keyboard, screensaver, updates); some define functions loaded via `defaults.zsh`

Load helper functions and run one-off tweaks:

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

### Get inspired

https://dotfiles.github.io/inspiration/