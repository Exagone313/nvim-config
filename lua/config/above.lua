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

-- Returns true if the given buffer is an "empty scratch": no file, not modified.
local function is_empty_scratch(bufnr)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	if vim.api.nvim_buf_get_name(bufnr) ~= "" then
		return false
	end
	if vim.bo[bufnr].modified then
		return false
	end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	return #lines == 0 or (#lines == 1 and lines[1] == "")
end

-- Picks the buffer that the file would land in if we used neo-tree's plain
-- "open" (which targets the previously-focused / first non-tree window).
local function target_buffer_for_open(state)
	-- When neo-tree took over the current window (position = "current"),
	-- the tree's window IS the target — replacing it with the file is desired.
	if state and state.current_position == "current" then
		return vim.api.nvim_get_current_buf()
	end
	local utils = require("neo-tree.utils")
	local winid = utils.get_appropriate_window(state)
	if winid and vim.api.nvim_win_is_valid(winid) then
		return vim.api.nvim_win_get_buf(winid)
	end
	return nil
end

local function open_node(state)
	local commands = require("neo-tree.sources.filesystem.commands")
	-- IDE mode: always open in the previously-used split (handled by
	-- open_files_in_last_window + commands.open).
	if require("config.ide").is_enabled() then
		commands.open(state)
		return
	end
	-- Float mode: replace the underlying buffer only if it's an empty
	-- unnamed scratch; otherwise open in a new tab. This applies uniformly
	-- to click and <CR> (default <CR> would have edited in place).
	if is_empty_scratch(target_buffer_for_open(state)) then
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
