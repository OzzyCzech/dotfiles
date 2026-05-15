# Homebrew (Apple Silicon) — sets PATH, MANPATH, INFOPATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# User bin directories
export PATH=$PATH:~/bin
export PATH=$PATH:~/.bin

# Rust/Cargo
export PATH=$PATH:~/.cargo/bin

# Bun
export PATH=$PATH:$HOME/.bun/bin

# pipx
export PATH=$PATH:$HOME/.local/bin