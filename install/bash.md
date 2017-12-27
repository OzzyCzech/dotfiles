# Bash

```
brew install bash
```

Open terminal ⌘+, setup path to new bash `/usr/local/bin/bash`

```
sudo code /etc/shells
```

add this line at the end of the list:

```
/usr/local/bin/bash
```

and

```
chsh -s /usr/local/bin/bash YOUR_USER_NAME
```

after that relaunch Terminal and check bash version

```
echo $BASH_VERSION
bash --version
```
