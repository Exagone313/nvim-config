-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("diffview").setup{
	use_icons = false,
}
require("fzf-lua").setup()
require("gitsigns").setup()

require("ibl").setup{
	indent = {
		char = "┊",
	},
	scope = {
		enabled = false,
	},
}
