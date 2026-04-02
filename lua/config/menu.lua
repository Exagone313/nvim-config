local Menu  = require("nui.menu")
local event = require("nui.utils.autocmd").event

local M = {}


function M.open()
	local bufnr = vim.api.nvim_get_current_buf()
	print(bufnr)

	local function hide_highlights()
		if vim.v.hlsearch then
			vim.cmd("nohlsearch")
		else
			vim.b[bufnr].hlsearch = true
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
			Menu.item("Hide highlights", {
				action = hide_highlights,
			}),
			Menu.item("test"),
			Menu.item("test"),
			Menu.item("test"),
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
