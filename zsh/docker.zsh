########################################################################################################################
# Docker
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose
########################################################################################################################

# docker compose
alias dc="docker compose "
function dce() { docker compose exec "$1" @2; }
function dcei() { docker compose exec -it "$1" /bin/bash; }

# docker
alias dps="docker ps"
alias dpa="docker system prune --all --force && docker image prune --all --force"
function de() { docker exec "$1" @2; }
function dei() { docker exec -it "$1" /bin/bash; }