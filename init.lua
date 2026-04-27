-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

local config_names = {
	"vim",
	"colors",
	"treesitter",
	"lsp",
	"directory",
	"above",
	"bars",
	"buffer",
}

for _, name in ipairs(config_names) do
	require("config." .. name)
end
