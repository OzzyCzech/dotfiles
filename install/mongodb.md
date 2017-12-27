# mongodb

Install [brew services](https://github.com/Homebrew/homebrew-services)

```
brew tap homebrew/services
```

```
brew install mongodb
brew link mongodb
```

Setup to autostart after login

```
sudo brew services start mongo
sudo brew services reload mongo
```