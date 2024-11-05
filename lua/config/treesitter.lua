-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("nvim-treesitter.configs").setup{
	ensure_installed = {
		"bash",
		"diff",
		"git_rebase",
		"gitcommit",
		"markdown",
		"markdown_inline",
		"python",
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
}
