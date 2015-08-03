# Install Docker on Mac

First install Cask http://caskroom.io/

    brew install caskroom/cask/brew-cask

Then install Docker and Virtualbox

    brew cask install virtualbox
    brew install docker
    brew install boot2docker
    
Then execute boot2docker

    boot2docker init
    boot2docker up
