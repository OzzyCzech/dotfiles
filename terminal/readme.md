
# Terminal

You can backup the current terminal settings using the `make backup.terminal` command, the file is converted to XML format during backup.

```shell
cp ~/Library/Preferences/com.apple.Terminal.plist terminal/com.apple.Terminal.plist
plutil -convert xml1 terminal/com.apple.Terminal.plist
```

If you need to restore the backup TO `~/Library/Preferences/com.apple.Terminal.plist`, you need to convert it back to a binary file:

```shell  
plutil -convert binary1 terminal/com.apple.Terminal.plist
cp terminal/com.apple.Terminal.plist ~/Library/Preferences/com.apple.Terminal.plist
```

Do not forget kill Terminal:

```shell
killall Terminal &> /dev/null
```

You can also download only my [Terminal.app color settings](https://raw.githubusercontent.com/OzzyCzech/dotfiles/terminal/main/OzzyCzech.terminal).

Set in Terminal configuration `⌘+,` in **Advanced > Declarative terminal** as `ansi` to enable numpad keyboard.