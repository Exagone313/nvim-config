-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("diffview").setup{
	use_icons = false,
}
require("fzf-lua").setup()
require("gitsigns").setup()

local ibl_highlight = {
    "CursorLine",
    "ColorColumn",
}
local ibl_hooks = require "ibl.hooks"
ibl_hooks.register(ibl_hooks.type.SKIP_LINE, function(_, _, _, line)
    return #line == 0
end)
require("ibl").setup{
	viewport_buffer = {
		min = 150,
	},
	indent = {
		highlight = ibl_highlight,
		char = "",
		tab_char = "⇥",
	},
	whitespace = {
		highlight = ibl_highlight,
		--remove_blankline_trail = false,
	},
	scope = {
		enabled = false,
	},
}
