-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("lualine").setup {
	options = {
		theme = "catppuccin-nvim",
		section_separators = "",
		component_separators = "",
		disabled_filetypes = {'neo-tree'},
	},
	sections = {
		lualine_a = {
			function()
				local mode = require('lualine.utils.mode').get_mode()
				return ("      " .. mode):sub(-7)
			end
		},
		lualine_b = {'branch', 'diff'},
		lualine_c = {
			'filename',
			{
				'diagnostics',
				on_click = function()
					vim.cmd("FzfLua lsp_document_diagnostics")
				end,
			},
		},
		lualine_x = {'lsp_status', 'encoding', 'fileformat', 'filetype', 'filesize'},
		lualine_y = {'progress', 'searchcount'},
		lualine_z = {'selectioncount', 'location'}
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

local default_dropbar_enable = require('dropbar.configs').opts.bar.enable
require("dropbar").setup{
	menu = {
		preview = false,
	},
	bar = {
		enable = function(buf, win, _)
			if vim.bo[buf].bt == 'terminal' or vim.bo[buf].ft == 'neo-tree' then
				return false
			end
			return default_dropbar_enable(buf, win, nil)
		end,
	},
}

vim.keymap.set("n", "<Leader>t", '<cmd>tab split<CR>')
vim.keymap.set("n", "<Tab>", "gt")
vim.keymap.set("n", "<S-Tab>", "gT")
