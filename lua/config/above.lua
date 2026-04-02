-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("notify").setup{
	minimum_width = 40,
	render = "wrapped-compact",
	top_down = false,
}
require("noice").setup()
require("which-key").setup{
	preset = "helix",
}
require("which-key").add({
	"<Leader>?",
	function()
		require("which-key").show({global = false})
	end,
	desc = "Which Key",
})
require("neo-tree").setup{
	close_if_last_window = true,
	window = {
		position = "float",
		mappings = {
			["<LeftRelease>"] = "open_tabnew",
			["<2-LeftMouse>"] = "open_tabnew",
			["e"] = "expand_all_subnodes",
		},
	},
	filesystem = {
		hijack_netrw_behavior = "open_current",
		filtered_items = {
			hide_dotfiles = false,
		},
		bind_to_cwd = false,
	},
	buffers = {
		bind_to_cwd = false,
	},
	event_handlers = {
		{
			event = "file_open_requested",
			handler = function(arg)
				require("neo-tree.command").execute({action = "close"})
			end
		}
	},
}
require("which-key").add({
	"<Leader>e",
	function()
		local buffer_id = vim.api.nvim_get_current_buf()
		if vim.fn.expand("%:p") == "" and not vim.api.nvim_buf_get_option(buffer_id, "modified") then
			require("neo-tree.command").execute({action = "focus", position = "current"})
			vim.api.nvim_buf_delete(buffer_id, {})
		else
			require("neo-tree.command").execute({action = "focus", dir = vim.fn.expand("%:p:h"), reveal = true})
		end
	end,
	desc = "Neotree",
})
local menu = require("config.menu")
require("which-key").add({
	"<Leader><Space>",
	function()
		menu:mount()
	end,
	desc = "Leader menu",
})
require("fzf-lua").setup()
