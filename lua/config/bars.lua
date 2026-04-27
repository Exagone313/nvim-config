-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("lualine").setup {
	options = {
		theme = "catppuccin",
		section_separators = "",
		component_separators = "",
	},
	extensions = {"neo-tree"},
	sections = {
		lualine_a = {
			function()
				local mode = require('lualine.utils.mode').get_mode()
				return ("      " .. mode):sub(-7)
			end
		},
		lualine_b = {'branch', 'diff'},
		lualine_c = {'filename', 'diagnostics'},
		lualine_x = {'lsp_status', 'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress', 'selectioncount', 'searchcount'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
}
require("dropbar").setup{
	menu = {
		preview = false,
	},
}

vim.keymap.set("n", "<Leader>t", '<cmd>tab split<CR>')
vim.keymap.set("n", "<Tab>", "gt")
vim.keymap.set("n", "<S-Tab>", "gT")
