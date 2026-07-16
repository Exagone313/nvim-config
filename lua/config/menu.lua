-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- AI-usage disclosure: some parts of this file were written by an AI model

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
		Menu.separator(" Fzf Lua "),
		Menu.item("Resume", {
			action = function()
				vim.cmd("FzfLua resume")
			end
		}),
		Menu.item("Live Grep", {
			action = function()
				vim.cmd("FzfLua live_grep")
			end
		}),
		Menu.item("Grep word", {
			action = function()
				vim.cmd("FzfLua grep_cword")
			end
		}),
		Menu.item("Files", {
			action = function()
				vim.cmd("FzfLua files")
			end
		}),
		Menu.item("Buffers", {
			action = function()
				vim.cmd("FzfLua buffers sort_lastused=false")
			end
		}),
		Menu.item("Tabs", {
			action = function()
				vim.cmd("FzfLua tabs fzf_opts.--header-lines=1")
			end
		}),
		Menu.item("Buffers in tab", {
			action = function()
				vim.cmd("FzfLua tabs current_tab_only=true")
			end
		}),
		Menu.item("LSP Diagnostics", {
			action = function()
				vim.cmd("FzfLua lsp_document_diagnostics")
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
		Menu.item("Keep only this tab", {
			action = function()
				vim.cmd("tabonly")
			end,
		}),
		Menu.item("Guess indent", {
			action = function()
				vim.cmd("GuessIndent silent")
			end,
		}),
		Menu.item("IDE mode", {
			action = function()
				require("config.ide").toggle()
			end,
		}),
		Menu.item("Terminal", {
			action = function()
				require("config.terminal").open()
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

	menu:on(event.BufLeave, function()
		menu:unmount()
	end)
end

return M
