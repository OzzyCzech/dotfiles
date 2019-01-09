#############################################################################
# load other files
#############################################################################

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases, and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

#############################################################################
# Prefer US English and use UTF-8
#############################################################################

export LC_ALL="en_US.UTF-8"
export LANG="en_US"

#############################################################################
# path
#############################################################################

export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH"

# Homebrew GitHub API rate limit exceeded
# see https://github.com/settings/tokens put new token to follow line and uncomment
# export HOMEBREW_GITHUB_API_TOKEN=XXXXXX
