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
require("fzf-lua").setup({
	tabs = {
		keymap = {
			fzf = {
				["focus"] = [[transform:[ {4} = 0 ] && case "$FZF_ACTION" in *up) echo up ;; *) echo down ;; esac]],
			},
		},
	},
})
