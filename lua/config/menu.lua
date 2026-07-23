-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- AI-usage disclosure: some parts of this file were written by an AI model

local Menu  = require("nui.menu")
local Line  = require("nui.line")
local Text  = require("nui.text")
local event = require("nui.utils.autocmd").event

local M = {}

-- Underline the shortcut letter with the same color as the float border,
-- leaving the letter's text color unchanged.
local function set_shortcut_hl()
	local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
	vim.api.nvim_set_hl(0, "MenuShortcut", {
		sp = border.fg,
		underline = true,
	})
end

set_shortcut_hl()

-- Re-apply after a colorscheme change so the color keeps matching the border.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("MenuShortcutHl", { clear = true }),
	callback = set_shortcut_hl,
})

-- Build a menu item from a label. A "&" before a character marks it as the
-- shortcut key: the character is displayed with the MenuShortcut highlight and
-- the lowercased character (in data.key) can be typed to jump to the entry.
local function item(label, data)
	local key = label:match("&(.)")
	local text = label:gsub("&", "")

	if not key then
		return Menu.item(text, data)
	end

	data = data or {}
	data.key = key:lower()

	local idx = label:find("&", 1, true)
	-- Column (in the "&"-stripped text) where the shortcut char starts.
	local before = label:sub(1, idx - 1):gsub("&", "")

	local line = Line()
	line:append(before)
	line:append(Text(key, "MenuShortcut"))
	line:append(text:sub(#before + #key + 1))

	return Menu.item(line, data)
end

function M.open()
	local origin_buf = vim.api.nvim_get_current_buf()

	local function toggle_highlights()
		if vim.v.hlsearch == 1 then
			vim.cmd("nohlsearch")
		else
			vim.cmd("set hlsearch")
		end
	end

	local lines = {
		item("Search highlights", {
			action = toggle_highlights,
		}),
		Menu.separator(" Fzf Lua "),
		item("&Resume", {
			action = function()
				vim.cmd("FzfLua resume")
			end
		}),
		item("Live Grep", {
			action = function()
				vim.cmd("FzfLua live_grep")
			end
		}),
		item("Grep &word", {
			action = function()
				vim.cmd("FzfLua grep_cword")
			end
		}),
		item("Files", {
			action = function()
				vim.cmd("FzfLua files")
			end
		}),
		item("Buffers", {
			action = function()
				vim.cmd("FzfLua buffers sort_lastused=false")
			end
		}),
		item("Tabs", {
			action = function()
				vim.cmd("FzfLua tabs fzf_opts.--header-lines=1")
			end
		}),
		item("Buffers in tab", {
			action = function()
				vim.cmd("FzfLua tabs current_tab_only=true")
			end
		}),
		item("LSP &Diagnostics", {
			action = function()
				vim.cmd("FzfLua lsp_document_diagnostics")
			end
		}),
		item("&Fzf Lua", {
			action = function()
				vim.cmd("FzfLua")
			end
		}),
		Menu.separator(" Git "),
		item("Git diff", {
			action = function()
				vim.cmd("DiffviewOpen")
			end
		}),
		item("Git blame", {
			action = function()
				vim.cmd("Gitsigns blame")
			end
		}),
		Menu.separator(" Other "),
		item("Help", {
			action = function()
				require("config.help").open()
			end,
		}),
		item("Keep only this tab", {
			action = function()
				vim.cmd("tabonly")
			end,
		}),
		item("Guess indent", {
			action = function()
				vim.cmd("GuessIndent silent")
			end,
		}),
		item("LSP Info", {
			action = function()
				require("config.lspinfo").open(origin_buf)
			end,
		}),
		item("&IDE mode", {
			action = function()
				require("config.ide").toggle()
			end,
		}),
		item("&Terminal", {
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

	-- Map shortcut keys to jump the cursor to the matching entry.
	for linenr = 1, #menu.tree:get_nodes() do
		local node = menu.tree:get_node(linenr)
		if node and node.key then
			menu:map("n", node.key, function()
				vim.api.nvim_win_set_cursor(menu.winid, { linenr, 0 })
			end, { noremap = true, nowait = true })
		end
	end

	menu:on(event.BufLeave, function()
		menu:unmount()
	end)
end

return M
