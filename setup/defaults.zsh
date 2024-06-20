SOURCE=${0%/*}

function info() { echo -e "\033[0;33m[ℹ] $1\033[0m"; }
function ok() { echo -e "\033[32m[✔]\033[0m \033[0;90m$1\033[0m"; }

source "$SOURCE/set-lock-message.zsh"
source "$SOURCE/set-screen-capture.zsh"