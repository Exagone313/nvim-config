#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
# SPDX-License-Identifier: BSD-3-Clause

set -e

cd "$(dirname "$0")"

# generate help tags
nvim --headless -c "helptags ALL" +q

# update tree-sitter parsers
nvim --headless -c "TSUpdate" +q; echo
