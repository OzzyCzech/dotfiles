# Brew Troubleshooting 

## Dubious Ownership

If you get error like: `Dubious ownership on file...` need to change plist rights:

```
sudo chown root ~/Library/LaunchAgents/*.plist
sudo chmod 644 ~/Library/LaunchAgents/*.plist
```

## System Integrity Protection issue

Fix [SIP protection](https://support.apple.com/en-us/HT204899) on El Capitan:

If you had created the `/usr/local` directory already, then run this command in terminal:

```
sudo chown $(whoami):admin /usr/local && sudo chown -R $(whoami):admin /usr/local
```

If you are doing a fresh install or cannot create /usr/local directory anymore, then follow these steps:

1. Reboot and hold on boot `Cmd+R`
2. In recovery run in Terminal command run `csrutil disable`
3. Reboot to El Capitan and run follow command in Terminal

```
sudo mkdir /usr/local && sudo chflags norestricted /usr/local && sudo chown $(whoami):admin /usr/local && sudo chown -R $(whoami):admin /usr/local
```

Then reboot to again recovery tool and return `csrutil enable`

## Change local Formulas

All local formulas can be found in paths:

```
/usr/local/Library/Formula
/usr/local/Library/Taps/homebrew/
```

It's a git repo, you can checkout any older source from github... https://github.com/Homebrew/homebrew-core