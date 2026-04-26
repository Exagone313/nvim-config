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

-- True if the buffer is an unnamed, unmodified, empty scratch buffer.
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
	if vim.bo[bufnr].filetype == "neo-tree" then
		return false
	end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	return #lines == 0 or (#lines == 1 and lines[1] == "")
end

-- True if the current tab has at least one non-tree, non-floating window
-- whose buffer is an empty scratch. This is what we want to "replace"
-- instead of opening a new tab.
local function tab_has_empty_scratch_window()
	local tabid = vim.api.nvim_get_current_tabpage()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
		local cfg_ok, cfg = pcall(vim.api.nvim_win_get_config, win)
		if cfg_ok and cfg.relative == "" then -- non-floating
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].filetype ~= "neo-tree" and is_empty_scratch(buf) then
				return true
			end
		end
	end
	return false
end

-- Resolve the path of the tree node currently under the cursor.
local function node_path(state)
	local ok, node = pcall(state.tree.get_node, state.tree)
	if not ok or not node then
		return nil
	end
	if node.type ~= "file" then
		return nil
	end
	return node.path or node:get_id()
end

local function open_node(state)
	local commands = require("neo-tree.sources.filesystem.commands")
	-- IDE mode: always open in the previously-used split (handled by
	-- open_files_in_last_window + commands.open).
	if require("config.ide").is_enabled() then
		commands.open(state)
		return
	end
	-- "current" position means neo-tree took over the user's window
	-- (typically via <Leader>e on an empty buffer) and is meant to be
	-- replaced by whatever they pick.
	if state and state.current_position == "current" then
		commands.open(state)
		return
	end
	-- Float over an existing layout: replace the empty scratch if the tab
	-- has one (e.g. fresh `nvim` then <Leader>e); otherwise open a new tab.
	if tab_has_empty_scratch_window() then
		commands.open(state)
		return
	end
	-- Otherwise: open in a new tab. Don't go through neo-tree's open_file
	-- (which routes through state.current_position and get_appropriate_window
	-- and has surprising edge cases for floats); just close the tree and run
	-- :tabnew ourselves.
	local path = node_path(state)
	if not path then
		-- Not a file (directory etc.): fall back to neo-tree's own handling.
		commands.open(state)
		return
	end
	require("neo-tree.command").execute({action = "close"})
	vim.cmd("tabnew " .. vim.fn.fnameescape(path))
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
			-- Pass position explicitly so a leftover state.current_position
			-- (e.g. "left" from a prior IDE-mode session on this tab)
			-- doesn't override the float layout.
			require("neo-tree.command").execute({action = "focus", position = "float", dir = vim.fn.expand("%:p:h"), reveal = true})
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
