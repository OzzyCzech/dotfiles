# AI aliases

### Claude aliases ###

alias c="claude --chrome --enable-auto-mode"

alias ca="claude agents" # Claude agents
alias cc="claude --chrome --continue" # Continue last session
alias cr="claude --chrome --resume" # Resume session (interactive picker)

# Claude paste from clipboard
cpaste() { pbpaste | claude --print "$@"; }

# Search
csearch() { claude --model haiku --allowedTools "WebSearch,WebFetch" --print "$@"; }

# Claude commit & push: check status, rebase if needed, split into logical commits, then push
csave() {
  claude -p --allowedTools "Bash(git *),WebFetch" <<'EOF'

  Perform a complete git workflow in the current repository:
  1. Run git status and git diff --stat to assess current state. If working tree is clean, stop.
  2. If on a branch tracking a remote, stash local changes, git pull --rebase, restore stash. Resolve conflicts if there are any.
  3. Analyze all changes (staged + unstaged) and group into logical, independent commits (feature, bugfix, refactor, docs, config…).
  4. For each group: stage relevant files/hunks with git add -p or git add <files>. Use commit messages in the same style as those in the Git history.
  5. Run git push. If push fails, report the error.
EOF
}

### Cursor aliases ###

alias cu="cursor ." # Cursor
