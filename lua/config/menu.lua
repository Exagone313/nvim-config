local Menu  = require("nui.menu")
local event = require("nui.utils.autocmd").event

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
		Menu.item("Toggle search highlights", {
			action = function()
				if vim.v.hlsearch then
					vim.cmd("nohlsearch")
				--else
					--vim.cmd("setl hlsearch")
				end
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

return menu
