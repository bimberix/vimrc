#!/usr/bin/env bash

cd "$(dirname "$(realpath ${0})")"

mkdir -p "${HOME}/.config/nvim"

ln -sf "$(pwd)/init.vim" "${HOME}/.config/nvim/"
ln -sf "$(pwd)/old.vim" "${HOME}/.config/nvim/"
ln -sf "$(pwd)/new.lua" "${HOME}/.config/nvim/"


