# macOS setup scripts

Scripts that configure macOS via `defaults write`. Run them individually as
needed — none of them run automatically on `make install`.

## Structure

| Folder      | Description                                                                                  |
|-------------|----------------------------------------------------------------------------------------------|
| `apps/`     | Per-application defaults (Dock, Finder, Mail, Terminal, …). Run directly: `zsh setup/apps/finder.zsh` |
| `system/`   | System and input devices. Some run directly (`inputs.zsh`, `keyboard.zsh`); the rest define helper functions sourced via `defaults.zsh`. |

### `apps/` scripts

`activity-monitor`, `dock`, `finder`, `image-capture`, `imessage`, `mail`,
`terminal`, `textedit`, `time-machine` — each applies its defaults when run:

```shell
zsh setup/apps/dock.zsh
zsh setup/apps/finder.zsh
```

### `system/` scripts

Run directly:

```shell
zsh setup/system/inputs.zsh     # save/print panels, trackpad, scrolling, sounds
zsh setup/system/keyboard.zsh   # key repeat, keyboard access mode
```

Function-based (sourced via `defaults.zsh`): `lock-message`, `screen-capture`,
`screensaver`, `software-updates`.

## Helper functions

Load the functions (defines `set-lock-message`, `set-screen-capture`,
`set-screen-saver`, `set-software-updates`):

```shell
source ./setup/defaults.zsh
```

Then call:

```shell
set-lock-message "Roman Ožana • roman@ozana.cz • +420 605 783 455"
set-screen-capture   # screenshots to ~/Downloads, PNG, no shadow/date
set-screen-saver     # screen saver after 5 min, require password immediately
set-software-updates # enable automatic update checks and downloads
```
