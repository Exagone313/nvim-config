-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

local Menu  = require("nui.menu")
local event = require("nui.utils.autocmd").event

local M = {}

function M.open()
	local function toggle_highlights()
		if vim.v.hlsearch == 1 then
			vim.cmd("nohlsearch")
		else
			vim.cmd("set hlsearch")
		end
	end

	local lines = {
		Menu.item("Search highlights", {
			action = toggle_highlights,
		}),
		Menu.separator(" List "),
		Menu.item("LSP Diagnostics", {
			action = function()
				vim.cmd("FzfLua lsp_document_diagnostics")
			end
		}),
		Menu.item("Tabs", {
			action = function()
				vim.cmd("FzfLua tabs")
			end
		}),
		Menu.item("Buffers", {
			action = function()
				vim.cmd("FzfLua buffers")
			end
		}),
		Menu.item("Buffers in tab", {
			action = function()
				vim.cmd("FzfLua tabs current_tab_only=true")
			end
		}),
		Menu.separator(" Git "),
		Menu.item("Git diff", {
			action = function()
				vim.cmd("DiffviewOpen")
			end
		}),
		Menu.item("Git blame", {
			action = function()
				vim.cmd("Gitsigns blame")
			end
		}),
		Menu.separator(" Other "),
		Menu.item("IDE mode", {
			action = function()
				require("config.ide").toggle()
			end,
		}),
	}

	local menu = Menu({
		position    = "50%",
		size        = {
			width = 32,
			height = math.max(2,
				math.min(#lines, vim.o.lines - 6)),
		},
		border      = {
			style = "rounded",
			text  = { top = " Leader ", top_align = "center" },
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			cursorline   = true,
		},
	},
	{
		lines = lines,
		keymap = {
			focus_next = { "j", "<Down>", "<Tab>" },
			focus_prev = { "k", "<Up>", "<S-Tab>" },
			close = { "<Esc>", "<C-c>" },
			submit = { "<CR>", "<Space>" },
		},
		on_submit = function(item)
			if item.action then
				item.action()
			end
		end,
	})

	menu:mount()
end

return M
