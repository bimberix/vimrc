#!/usr/bin/env bash

cd "$(dirname "$(realpath ${0})")"

mkdir -p "${HOME}/.config/nvim"

rm -rf "${HOME}/.config/nvim"
ln -s "$(pwd)/config" "${HOME}/.config/nvim"

