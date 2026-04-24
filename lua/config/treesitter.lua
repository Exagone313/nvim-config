-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require('nvim-treesitter').install {
	"bash",
	"c",
	"css",
	"csv",
	"diff",
	"go",
	"html",
	"java",
	"javascript",
	"json",
	"jsx",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"toml",
	"tsv",
	"tsx",
	"typescript",
	"vim",
	"xml",
	"yaml",
	"zig",
}

vim.api.nvim_create_autocmd('FileType', {
	pattern = {
		"bash",
		"c",
		"css",
		"csv",
		"diff",
		"go",
		"html",
		"java",
		"javascript",
		"javascriptreact",
		"json",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"python",
		"sh",
		"toml",
		"tsv",
		"typescript",
		"typescriptreact",
		"vim",
		"xml",
		"yaml",
		"zig",
	},
	callback = function()
		vim.treesitter.start()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
