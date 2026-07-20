-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require("diffview").setup{
	use_icons = false,
	view = {
		merge_tool = {
			layout = "diff3_mixed",
		}
	},
}
require("gitsigns").setup()

local ibl_hooks = require "ibl.hooks"
ibl_hooks.register(ibl_hooks.type.SKIP_LINE, function(_, _, _, line)
	return #line == 0
end)
require("ibl").setup{
	viewport_buffer = {
		min = 150,
	},
	indent = {
		char = "",
		tab_char = "⇥",
	},
	whitespace = {
	},
	scope = {
		enabled = false,
	},
}

require("mini.trailspace").setup()

require("guess-indent").setup{
	override_editorconfig = true,
}

require("conform").setup({
	formatters_by_ft = {
		bash = {"shellcheck"},
		c = {"clang-format"},
		cpp = {"clang-format"},
		go = {"gofmt"},
		javascript = {"deno_fmt", lsp_format = "prefer"},
		javascriptreact = {"deno_fmt", lsp_format = "prefer"},
		markdown = {"deno_fmt"},
		python = {"ruff_fix", "ruff_format"},
		sh = {"shellcheck"},
		typescript = {"deno_fmt", lsp_format = "prefer"},
		typescriptreact = {"deno_fmt", lsp_format = "prefer"},
		zig = {"zigfmt"},
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({"n", "v"}, "<Leader>p", '"+p')
vim.keymap.set({"n", "v"}, "<Leader>P", '"+P')
vim.keymap.set("v", "<Leader>y", '"+y')
vim.keymap.set({"n", "v"}, "<Leader>Y", '"+Y')

-- fix line yanking in Neovim 0.6+
pcall(vim.keymap.del, "n", "Y")
