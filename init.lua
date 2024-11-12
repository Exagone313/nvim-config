-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

local config_names = {
	"vim",
	"colors",
	"treesitter",
	"lsp",
	"top",
	"buffer",
	"bottom",
}

for _, name in ipairs(config_names) do
	require("config." .. name)
end
