# macOS setup scripts

Skripty pro nastavení macOS (`defaults write`). Spouštěj jednotlivě podle potřeby.

## Struktura

| Složka   | Popis |
|----------|--------|
| **apps/**   | Nastavení konkrétních aplikací (Dock, Finder, Mail, Terminal, …). Spustit: `zsh setup/apps/finder.zsh` |
| **system/** | Systém a vstupní zařízení (klávesnice, trackpad, screensaver, updates). Některé soubory definují funkce – načti je přes `defaults.zsh`. |

## Použití

Načti funkce (např. `set-lock-message`, `set-screen-capture`):

```shell
source ./setup/defaults.zsh
```

Pak můžeš volat např.:

```shell
set-lock-message "Roman Ožana • roman@ozana.cz • +420 605 783 455"
set-screen-capture   # nastaví screenshoty do ~/Downloads
set-screen-saver     # vypne screensaver, vyžaduje heslo hned
set-software-updates # zapne automatické aktualizace
```

Jednorázové nastavení aplikací nebo systému:

```shell
zsh setup/apps/dock.zsh
zsh setup/apps/finder.zsh
zsh setup/system/keyboard.zsh
```
