-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

--require("bufferline").setup{
--	highlights = require("catppuccin.groups.integrations.bufferline").get{
--		styles = {},
--	},
--	options = {
--		mode = "tabs",
--		numbers = function(opts)
--			return string.format("%s", opts.lower(opts.id))
--		end,
--		show_duplicate_prefix = false,
--		show_tab_indicators = false,
--		indicator = {
--			style = "none",
--		},
--		right_mouse_command = "",
--		middle_mouse_command = "bdelete! %d",
--		--middle_mouse_command = function(bufnum)
--		--	local found_tab = nil
--		--end,
--		diagnostics = "nvim_lsp",
--		diagnostics_indicator = function(_, level)
--			local icon = level:match("error") and " " or " "
--			return " " .. icon
--		end,
--	},
--}
require("dropbar").setup{
	menu = {
		preview = false,
	},
}

vim.keymap.set("n", "<Leader>t", '<cmd>tab split<CR>')
--vim.keymap.set("n", "<Tab>", function()
--	require("bufferline").cycle(1)
--end)
--vim.keymap.set("n", "<S-Tab>", function()
--	require("bufferline").cycle(-1)
--end)
vim.keymap.set("n", "<Tab>", "gt")
vim.keymap.set("n", "<S-Tab>", "gT")
