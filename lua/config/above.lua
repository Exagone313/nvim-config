-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
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

local function open_node(state)
	local commands = require("neo-tree.sources.filesystem.commands")
	if require("config.ide").is_enabled() then
		commands.open(state)
	else
		commands.open_tabnew(state)
	end
end

require("neo-tree").setup{
	close_if_last_window = true,
	open_files_in_last_window = true,
	window = {
		position = "float",
		mappings = {
			["<LeftRelease>"] = open_node,
			["<2-LeftMouse>"] = open_node,
			["<CR>"]          = open_node,
			["e"]             = "expand_all_subnodes",
		},
	},
	filesystem = {
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
				local pos = arg and arg.state and arg.state.current_position
				if pos == "left" or pos == "right" or pos == "top" or pos == "bottom" then
					return
				end
				if require("config.ide").is_enabled() then
					return
				end
				require("neo-tree.command").execute({action = "close"})
			end
		}
	},
}
require("which-key").add({
	"<Leader>e",
	function()
		if require("config.ide").is_enabled() then
			require("neo-tree.command").execute({
				action   = "focus",
				source   = "filesystem",
				position = "left",
				reveal   = true,
			})
			return
		end
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
	menu.open,
	desc = "Leader menu",
})
require("fzf-lua").setup()
