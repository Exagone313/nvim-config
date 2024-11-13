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
--	custom_highlights = function(colors)
--		return {
--			Whitespace = {
--				fg = "Red",
--			},
--		}
--	end,
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
