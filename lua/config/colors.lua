-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("catppuccin").setup{
	flavour = "macchiato",
	dim_inactive = {
		enabled = true,
	},
	styles = {
		comments = {},
		conditionals = {},
	},
	integrations = {
		blink_cmp = true,
		diffview = true,
	},
}

vim.cmd.colorscheme("catppuccin-macchiato")
