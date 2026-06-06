#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

if [ -d ~/.config/nvim ] && ! [ -L ~/.config/nvim ]; then
	mv -v -i ~/.config/nvim{,.bak}
fi

mkdir -p ~/.config
ln -srvfT "${PWD}" ~/.config/nvim
