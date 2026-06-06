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

local menu = require("config.menu")
require("which-key").add({
	"<Leader><Space>",
	menu.open,
	desc = "Leader menu",
})


local function tabs_previewer_ctor()
	local builtin = require("fzf-lua.previewer.builtin")
	local TabsPreviewer = builtin.buffer_or_file:extend()
	function TabsPreviewer:parse_entry(entry_str, _cb)
		if type(entry_str) == "string" and entry_str:match("^[^\t]*\t%d+\t%d+\t0%)") then
			return { content = {} }
		end
		return TabsPreviewer.super.parse_entry(self, entry_str, _cb)
	end
	return TabsPreviewer
end

require("fzf-lua").setup({
	winopts = {
		-- workaround for FzFLua not going into insert mode when opened from lualine
		on_create = function()
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_create_autocmd("ModeChanged", {
				buffer = buf,
				callback = function(e)
					if e.match == "n:nt" and vim.api.nvim_get_current_buf() == buf then
						vim.cmd("startinsert")
					end
				end,
			})
		end,
	},
	tabs = {
		keymap = {
			fzf = {
				["focus"] = [[transform:[ {4} = 0 ] && case "$FZF_ACTION" in *up) echo up ;; *) echo down ;; esac]],
			},
		},
		previewer = {
			_ctor = tabs_previewer_ctor,
		},
	},
	actions = {
		files = {
			true,
			["enter"] = require("fzf-lua.actions").file_edit,
		},
	},
})
