#!/bin/zsh

# This script will remove any existing version and install version specified
# Usage zsh install_go.zsh <VERSION>
# Example zsh install_go.zsh  1.14

if [[ $1 == '' ]];then
    echo "Specify version to download and try again!"
    exit 1
fi

VERSION=$1

echo "Downloading version $VERSION"
wget "https://dl.google.com/go/go$VERSION.linux-amd64.tar.gz" -P ~/Downloads

if [ $? != 0 ];then
    echo "Unable to download, please review the version specified"
    exit 1
fi

if [ -d /usr/local/go ];then
    echo "Removing existing version in the system"
    sudo rm -rf /usr/local/go
fi

echo "Installing version $VERSION to /usr/local, you will be prompted for sudo password"
sudo tar -C /usr/local -xzf ~/Downloads/go$VERSION.linux-amd64.tar.gz

echo "Adding to PATH in current shell"
export PATH=$PATH:/usr/local/go/bin
echo 'Add this to ~/.zshrc export PATH=$PATH:/usr/local/go/bin'

echo "Check current go version"
go version
