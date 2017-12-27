#!/bin/bash

#
# Usage sh backup.brew.sh > restore.brew.sh
#
# Sources
# - https://gist.github.com/xuhdev/7854010
#
#

echo '#!/bin/bash'
echo '#'
echo '# # # DO NOT RUN AS SUDO !!! # # #'
echo '#'
echo 'ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"'

echo ''
echo '# tap'
brew tap | while read tap; do echo "brew tap $tap"; done

echo ''
echo '# upgrade brew'
echo 'brew update && brew upgrade'

echo ''
echo '# install all items'
brew list | while read item;
do  
  echo "brew install $item '$(brew info $item | /usr/bin/grep -m 1 'Built from source with:' | /usr/bin/sed 's/^[ \t]*Built from source with:/ /g; s/\,/ /g')'"
done


echo 'brew cleanup'
