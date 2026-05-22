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
brew install git zsh zsh-completions antidote powerlevel10k
```

- [Zsh](https://www.zsh.org/) — interactive shell
- [Zsh Completions](https://github.com/zsh-users/zsh-completions) — extra completions
- [Antidote](https://getantidote.github.io) — fast Zsh plugin manager
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) — prompt theme
- [Git](https://git-scm.com/) — version control

Set Zsh as default shell:

```shell
chsh -s /bin/zsh
```

## Repository structure

| Directory      | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `zsh/`         | Zsh config — aliases, paths, prompt, history, AI helpers, Docker, eza, etc. |
| `bin/`         | Compiled utilities (`del`, `encode64`, `passgen`, `mac-cleanup`, `mac-upgrade`) |
| `utils/`       | Swift source for utilities in `bin/`                                        |
| `setup/`       | macOS defaults scripts (Finder, Dock, keyboard, …) — see `setup/readme.md` |
| `apps/`        | Homebrew and Mac App Store app lists (`brew-list.txt`, `mas-list.txt`, …)   |
| `config/`      | App configs (Zed, Ghostty, cmux, yt-dlp) — symlinked into `~/.config/`      |
| `icns/`        | Custom volume icons                                                         |

## What `make install` does

1. Creates `~/.hushlogin`
2. Symlinks git config (`.gitconfig`, `.gitignore_global`) and sets `core.excludesfile`
3. Symlinks zsh dotfiles (`.zshrc`, `.zsh_plugins.txt`, `.p10k.zsh`, `.zprofile`) and directories (`zsh/` → `~/.zsh`, `bin/` → `~/.bin`)
4. Symlinks `config/` entries into `~/.config/` (Zed, Ghostty, cmux, yt-dlp)

## Utilities

Compile Swift utilities into `bin/`:

```shell
make utils
```

| Utility    | Description                            |
|------------|----------------------------------------|
| `del`         | Move files to Trash (safe delete)      |
| `encode64`    | Base64 encode/decode                   |
| `passgen`     | Generate passwords and passphrases     |
| `mac-cleanup` | Shell script — clean caches/logs/Trash |
| `mac-upgrade` | Shell script — upgrade brew, mas, npm  |

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
- oh-my-zsh: git, gitfast, docker, docker-compose, extract, httpie, rsync
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smarter `cd` (replaces `wd`); seed history with `zsh setup/zoxide-seed.zsh`

## Prompt

The prompt is [Powerlevel10k](https://github.com/romkatv/powerlevel10k) configured
to look like the classic [robbyrussell](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#robbyrussell)
oh-my-zsh theme — same `➜ dir git:(branch) ✗` style, just rendered with
async git status and instant-prompt support for snappier startup.

The config in `.p10k.zsh` is a copy of the `p10k-robbyrussell.zsh` template
shipped with Powerlevel10k. Tweak it directly or run `p10k configure` to
generate a different style.

## Backup SSH keys

```shell
zip -r ~/Downloads/ssh.zip ~/.ssh
```

## Get inspired

https://dotfiles.github.io/inspiration/
