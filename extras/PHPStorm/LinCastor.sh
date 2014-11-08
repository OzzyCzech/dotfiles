#!/bin/sh
# the script will execute with following environmental variables defined:
#   URL_SCHEME   => my-http
#   URL_HOST     => myhost.domain.com
#   URL_PORT     => 8080
#   URL_QUERY    => ?search=blah
#   URL_PATH     => /mysite/a.html
#   URL_FRAGMENT => #myanchor
#
#   HOME => the user's home directory (if any)
#
# you should exit with 0, this means the handler has finished succesfully
# non-zero value indicates an error

REGEX="^url=file://(.*)&line=(.*)$"

if [[ $URL_QUERY =~ $REGEX ]]; then
    #Depending on which version of PHPStorm you're running, uncomment the appropriate app name:
    #osascript -e "tell application \"PhpStorm EAP\" to activate"
    #osascript -e "tell application \"PhpStorm\" to activate"
    /usr/local/bin/storm "${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
    exit 0
fi

exit 1