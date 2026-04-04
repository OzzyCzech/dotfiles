# OzzyCzech's dotfiles

Personal macOS config. Zsh, Antidote, and helpers.

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
brew install git zsh zsh-completions antidote
```

- [Zsh](https://www.zsh.org/) — interactive shell
- [Zsh Completions](https://github.com/zsh-users/zsh-completions) — extra completions
- [Antidote](https://getantidote.github.io) — fast Zsh plugin manager
- [Git](https://git-scm.com/) — version control

Set Zsh as default shell:

```shell
chsh -s /bin/zsh
```

## Repository structure

| Directory      | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `zsh/`         | Zsh config — aliases, paths, prompt, history, AI helpers, Docker, eza, etc. |
| `bin/`         | Compiled utilities (`backup`, `del`, `encode64`, `passgen`, `mac-cleanup`, `mac-upgrade`) |
| `utils/`       | Swift source for utilities in `bin/`                                        |
| `setup/`       | macOS defaults scripts (Finder, Dock, keyboard, …) — see `setup/readme.md` |
| `apps/`        | Homebrew and Mac App Store app lists (`brew-list.txt`, `mas-list.txt`, …)   |
| `configs/`     | Backed-up app configs (VS Code, Cursor, Ghostty, Terminal)                  |
| `terminal/`    | Terminal & iTerm themes and profiles                                        |
| `icns/`        | Custom volume icons                                                         |

## What `make install` does

1. Creates `~/.hushlogin`
2. Copies app configs from `configs/` to `~/.config/`
3. Copies `.gitconfig` to `~/`
4. Symlinks dotfiles (`.ackrc`, `.gitignore`, `.zshrc`, `.zsh_plugins.txt`) and directories (`zsh/` → `~/.zsh`, `bin/` → `~/.bin`)
5. Preserves existing git `user.name`, `user.email`, and `user.username`

## Utilities

Compile Swift utilities into `bin/`:

```shell
make utils
```

| Utility    | Description                            |
|------------|----------------------------------------|
| `backup`   | Backup files by path or JSON config    |
| `del`      | Move files to Trash (safe delete)      |
| `encode64` | Base64 encode/decode                   |
| `passgen`  | Generate passwords and passphrases     |

### Backup

```shell
backup <source1> <source2> ... <out-directory>
backup -c backup.json configs
```

The included `backup.json` defines paths for Zed, VS Code, Cursor, Ghostty, Terminal, Claude, and others. Run `make backup` to refresh app lists, terminal prefs, and configs in one step.

## Setup scripts

Scripts in `setup/` configure macOS defaults. Run individually:

```shell
zsh setup/apps/finder.zsh
zsh setup/apps/dock.zsh
zsh setup/system/keyboard.zsh
```

Load helper functions:

```shell
source ./setup/defaults.zsh
```

Then use:

```shell
set-lock-message "Roman Ozana • roman@ozana.cz • +420 605 783 455"
set-screen-capture   # screenshots to ~/Downloads
set-screen-saver     # disable screensaver, require password immediately
set-software-updates # enable automatic updates
```

## Zsh plugins

Managed by [Antidote](https://getantidote.github.io) via `.zsh_plugins.txt`:

- [zsh-completions](https://github.com/zsh-users/zsh-completions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- oh-my-zsh: git, docker, docker-compose, extract, httpie, rsync, aliases, yarn, wd

## Backup SSH keys

```shell
zip -r ~/Downloads/ssh.zip ~/.ssh
```

## Get inspired

https://dotfiles.github.io/inspiration/
