-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.list = true
vim.opt.listchars = {tab = "  ", trail = " ", nbsp = " ", lead = "·"}
vim.opt.scrolloff = 2
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showtabline = 2
vim.opt.title = true
vim.opt.runtimepath:append(vim.fn.stdpath("config") .. "/pack/submodule/start/*/doc")

vim.g.mapleader = ","
vim.g.load_black = false
vim.g.omni_sql_no_default_maps = true

vim.go.pumheight = 15

vim.filetype.add({
	extension = {
		container = "systemd",
		pod = "systemd",
	},
})
