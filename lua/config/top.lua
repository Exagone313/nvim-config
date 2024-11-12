-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("barbecue").setup()
require("bufferline").setup{
	highlights = require("catppuccin.groups.integrations.bufferline").get{
		styles = {}
	},
	options = {
		mode = "tabs",
		numbers = "none",
		always_show_bufferline = false,
		show_duplicate_prefix = false,
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(_, level)
			local icon = level:match("error") and " " or " "
			return " " .. icon
		end
	},
}
