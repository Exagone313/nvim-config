-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
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
		dropbar = {
			enabled = true,
		},
		fzf = true,
		gitsigns = true,
		indent_blankline = {
			enabled = true,
		},
		neotree = true,
		noice = true,
		treesitter = true,
		which_key = true,
	},
}

vim.cmd.colorscheme("catppuccin-macchiato")
