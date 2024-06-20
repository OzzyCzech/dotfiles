function random-password() {
  local length="${1:-24}"
  ruby -r securerandom -e "puts SecureRandom.base64($length)" | tr -d "[:punct:]" 2> /dev/null
}

alias mkpasswd=random-password