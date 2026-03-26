# AI aliases

### Claude aliases ###

alias c="claude --enable-auto-mode"
alias c2="CLAUDE_CONFIG_DIR=~/.claude2 claude --enable-auto-mode"

# Claude with dangerous permissions
alias xc="claude --dangerously-skip-permissions"
alias xco="claude --model opus --dangerously-skip-permissions"
alias xch="claude --model haiku --dangerously-skip-permissions"
alias xcs="claude --model sonnet --dangerously-skip-permissions"

# Claude model aliases
alias ch="claude --model haiku" # Claude Haiku
alias cs="claude --model sonnet" # Claude Sonnet
alias co="claude --model opus" # Claude Opus

# Claude paste from clipboard
cpaste() { pbpaste | claude --print "$@"; }

# Search
csearch() { claude --model haiku --allowedTools "WebSearch,WebFetch" --print "$@"; }

### Cursor aliases ###

alias cr="cursor ." # Cursor
