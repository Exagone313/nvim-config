#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
# SPDX-License-Identifier: BSD-3-Clause

set -e

cd "$(dirname "$0")"

git pull
git submodule update --init --recursive
