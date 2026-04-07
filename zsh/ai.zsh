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

# Claude commit & push: check status, rebase if needed, split into logical commits, then push
ccp() {
  claude -p --allowedTools "Bash(git *),WebFetch" <<EOF
  Perform a complete git workflow in the current repository:
  1. Run git status and git diff --stat to assess current state. If working tree is clean, stop.
  2. If on a branch tracking a remote, stash local changes, git pull --rebase, restore stash. Resolve conflicts if there are any.
  3. Analyze all changes (staged + unstaged) and group into logical, independent commits (feature, bugfix, refactor, docs, config…).
  4. For each group: stage relevant files/hunks with git add -p or git add <files>. Use commit messages in the same style as those in the Git history.
  5. Run git push. If push fails, report the error.
EOF
}

### Cursor aliases ###

alias cr="cursor ." # Cursor
