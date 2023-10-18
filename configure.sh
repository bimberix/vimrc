#!/usr/bin/env bash

cd "$(dirname "$(realpath ${0})")"

mkdir -p "${HOME}/.config/nvim"

rm -rf "${HOME}/.config/nvim"
ln -s "$(pwd)/config" "${HOME}/.config/nvim"


#sudo apt install python3-pip shellcheck clangd ctags xsel xclip
#curl -sL install-node.now.sh/lts | bash -s -- --prefix="${HOME}/.local"
#npm i -g bash-language-server
#pip3 install pyright
