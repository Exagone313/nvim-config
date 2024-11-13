-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("neo-tree").setup{
	close_if_last_window = true,
	filesystem = {
		hijack_netrw_behavior = "open_current",
	},
	window = {
		position = "right",
		width = "22",
	},
	event_handlers = {
		{
			event = "file_opened",
			--event = "neo_tree_buffer_leave",
			handler = function(arg)
				--print("hello")
				--vim.cmd(":Neotree action=close")
				require("neo-tree.command").execute({action = "close"})
			end
		}
	},
}

vim.keymap.set("n", "<Leader>e", function()
	local buffer_id = vim.api.nvim_get_current_buf()
	if vim.fn.expand("%:p") == "" and not vim.api.nvim_buf_get_option(buffer_id, 'modified') then
		require("neo-tree.command").execute({action = "focus", position = "current"})
		vim.api.nvim_buf_delete(buffer_id, {})
	else
		require("neo-tree.command").execute({action = "focus"})
	end
end)

--if vim.fn.argc(-1) == 0 then
--	vim.cmd("")
--end
