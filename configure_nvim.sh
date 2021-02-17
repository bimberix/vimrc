#!/usr/bin/env bash

cd "$(dirname "$(realpath ${0})")"

mkdir -p "${HOME}/.config/nvim"

ln -sf "$(pwd)/.vimrc" "${HOME}/"
ln -sf "$(pwd)/init.vim" "${HOME}/.config/nvim/"
ln -sf "$(pwd)/coc-settings.json" "${HOME}/.config/nvim/"

curl -sL install-node.now.sh/lts | bash -s -- --prefix="${HOME}/.local"

sudo apt install python3-pip shellcheck ctags xsel xclip

mkdir -p "${HOME}/.local/bin"
mkdir -p "${HOME}/.local/lib"
cd "${HOME}/.local/lib"
npm install yarn
ln -sf "$(pwd)/node_modules/yarn/bin/yarn" "${HOME}/.local/bin/"

pip3 install jedi-language-server pylint black isort docformatter
