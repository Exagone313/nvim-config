-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

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

-- True if the current tab has any non-floating, non-tree window whose buffer
-- is unnamed AND modified — i.e. the user has unsaved typed content in a
-- scratch buffer that we mustn't lose by replacing it.
local function tab_has_unnamed_modified_window()
	local tabid = vim.api.nvim_get_current_tabpage()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
		local cfg_ok, cfg = pcall(vim.api.nvim_win_get_config, win)
		if cfg_ok and cfg.relative == "" then -- non-floating
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.api.nvim_buf_is_valid(buf)
				and vim.bo[buf].filetype ~= "neo-tree"
				and vim.api.nvim_buf_get_name(buf) == ""
				and vim.bo[buf].modified
			then
				return true
			end
		end
	end
	return false
end

local function open_node(state)
	local commands = require("neo-tree.sources.filesystem.commands")
	-- IDE mode: open in the previously-used split (handled by
	-- open_files_in_last_window + commands.open).
	if require("config.ide").is_enabled() then
		commands.open(state)
		return
	end
	-- Default: open in the current tab (replacing whatever's there). The
	-- only exception is an unnamed, modified scratch buffer in this tab,
	-- which we shouldn't clobber — open in a new tab instead.
	if tab_has_unnamed_modified_window() then
		local path = node_path(state)
		if path then
			require("neo-tree.command").execute({action = "close"})
			vim.cmd("tabnew " .. vim.fn.fnameescape(path))
			return
		end
	end
	commands.open(state)
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
			["<Left>"]        = "navigate_up",
			["<Right>"]       = open_node,
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
	source_selector = {
		statusline = true,
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
			require("neo-tree.command").execute({
				action   = "focus",
				position = "current",
				selector = false,
			})
			vim.api.nvim_buf_delete(buffer_id, {})
		else
			-- Pass position explicitly so a leftover state.current_position
			-- (e.g. "left" from a prior IDE-mode session on this tab)
			-- doesn't override the float layout.
			require("neo-tree.command").execute({
				action   = "focus",
				position = "float",
				dir      = vim.fn.expand("%:p:h"),
				reveal   = true,
				selector = false,
			})
		end
	end,
	desc = "Neotree",
})
