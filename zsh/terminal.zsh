# Ghostty and cmux set TERM=xterm-ghostty with TERMINFO pointing into the app
# bundle. Remote hosts don't know that entry and sudo drops TERMINFO, so fall
# back for those two. Ghostty's ssh-env/sudo shell integration features replace
# these functions when enabled.
[[ $TERM == xterm-ghostty ]] || return 0

ssh() { TERM=xterm-256color command ssh "$@" }

sudo() {
  local arg
  for arg in "$@"; do
    # sudoedit (-e/--edit) does not accept --preserve-env
    [[ $arg == -e || $arg == --edit ]] && { command sudo "$@"; return }
    [[ $arg != -* && $arg != *=* ]] && break
  done
  command sudo --preserve-env=TERMINFO "$@"
}
