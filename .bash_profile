#############################################################################
# load other files
#############################################################################

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases,  ~/.shortcuts and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions,shortcuts}; do
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

# Configure right paths for gcc compiler to look on libs install with brew
# same as run ./configure LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
