-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

require('nvim-treesitter').install {
	"bash",
	"diff",
	"git_rebase",
	"gitcommit",
	"markdown",
	"markdown_inline",
	"python",
}

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'bash', 'sh', 'diff', 'gitrebase', 'gitcommit', 'markdown', 'python' },
	callback = function()
		vim.treesitter.start()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
