# AI aliases

### Claude aliases ###

alias c="claude"

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
alias cpaste='pbpaste | claude --print "$@"' # Claude paste from clipboard

# Seach
alias csearch='claude --model haiku --allowedTools "WebSearch,WebFetch" --print "$@"'

### Cursor aliases ###

alias cr="cursor ." # Cursor