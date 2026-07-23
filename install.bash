#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
# SPDX-License-Identifier: BSD-3-Clause

set -e

cd "$(dirname "$0")"

git submodule update --init --recursive

if [ -d ~/.config/nvim ] && ! [ -L ~/.config/nvim ]; then
	mv -v -i ~/.config/nvim{,.bak}
fi

mkdir -p ~/.config
ln -srvfT "${PWD}" ~/.config/nvim

source ./post-install.bash
