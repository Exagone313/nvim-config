-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

local Menu  = require("nui.menu")
local event = require("nui.utils.autocmd").event

local M = {}

function M.open()
	--local bufnr = vim.api.nvim_get_current_buf()

	local function toggle_highlights()
		if vim.v.hlsearch == 1 then
			vim.cmd("nohlsearch")
		else
			vim.cmd("set hlsearch")
		end
	end

	local menu = Menu({
		position    = "50%",
		size        = { width = 32, height = 7 },
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
		lines = {
			Menu.item("Toggle highlights", {
				action = toggle_highlights,
			}),
			Menu.separator(" Git ", {
			}),
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
		},
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
