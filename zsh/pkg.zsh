# Package updates via taze
alias pup="npx taze minor --write --install --interactive --include-locked"
alias pupr="npx taze minor --write --recursive --install --interactive --include-locked --mirror"
alias pupg="npx taze major --write --install --interactive --include-locked --global"

# npm
alias npm-list-globals="npm list -g --depth 0"

# Composer — ignore platform requirements (handy when local PHP differs from project's)
alias composer="COMPOSER_IGNORE_PLATFORM_REQS=1 composer"
