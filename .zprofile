eval "$(/opt/homebrew/bin/brew shellenv)"
# Homebrew's rustup is keg-only; only `rustup` itself is linked, cargo and rustc proxies live here
export PATH=$PATH:$HOMEBREW_PREFIX/opt/rustup/bin
source ~/.orbstack/shell/init.zsh 2>/dev/null || : # https://orbstack.dev/
