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
})
