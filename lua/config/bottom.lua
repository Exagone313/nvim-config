-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("lualine").setup {
	options = {
		theme = "catppuccin",
		section_separators = "",
		component_separators = "",
		disabled_filetypes = {
			statusline = {
				"neo-tree",
			},
		},
	},
	sections = {
		lualine_a = {
			function()
				local mode = require('lualine.utils.mode').get_mode()
				return ("      " .. mode):sub(-7)
			end
		},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
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
	tabline = {
		lualine_a = {
		},
		lualine_b = {
			{
				'tabs',
				max_length = vim.o.columns,
				mode = 1,
				path = 1,
			}
		},
		lualine_c = {
		},
		lualine_x = {
		},
		lualine_y = {
		},
		lualine_z = {
		}
	}
}
