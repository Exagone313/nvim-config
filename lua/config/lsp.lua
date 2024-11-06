-- Copyright (C) 2024 Elouan Martinet <exa@elou.world>
-- SPDX-FileCopyrightText: 2024 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Disable syntax highlighting as Treesitter provides it already and is faster
	client.server_capabilities.semanticTokensProvider = nil

	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local _, lspconfig = pcall(require, 'lspconfig')

-- This function is adapted from code made by Konstantin Gorodinskiy, Copyright 2012-2023, MIT license
-- https://github.com/gko/vimio
function lsp_binary_exists(server_config)
	if not (server_config.document_config and server_config.document_config.default_config and type(server_config.document_config.default_config.cmd) == "table" and #server_config.document_config.default_config.cmd >= 1) then
		return false
	end
	return vim.fn.executable(server_config.document_config.default_config.cmd[1]) == 1
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {
	['bashls'] = {},
	['cssls'] = {},
	['clangd'] = {},
	['eslint'] = {},
	['html'] = {},
	['jsonls'] = {},
	['rubocop'] = {},
	['ruff'] = {}, -- TODO fallback to pyright, pylsp in this order
	['terraformls'] = {},
	['yamlls'] = {
		settings = {
			yaml = {
				schemaStore = {
					url = "https://www.schemastore.org/api/json/catalog.json",
					enable = true,
				},
				customTags = {
					"!reference sequence",
				},
			},
		},
	},
}
for server, options in pairs(servers) do
	if lspconfig[server] and lspconfig[server].setup and lsp_binary_exists(lspconfig[server]) then
		options.on_attach = on_attach
		options.capabilities = require('blink-cmp').get_lsp_capabilities(options.capabilities)
		--print(vim.inspect(options))
		lspconfig[server].setup(options)
	end
end

require("blink-cmp").setup{
	keymap = {
		['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
		['<Esc>'] = { 'hide', 'fallback' },
		['<C-p>'] = { 'select_and_accept', 'fallback' },
		['<Up>'] = { 'select_prev', 'fallback' },
		['<Down>'] = { 'select_next', 'fallback' },
		['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
		['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
		['<Tab>'] = { 'snippet_forward', 'fallback' },
		['<S-Tab>'] = { 'snippet_backward', 'fallback' },
	},
	trigger = {
		signature_help = {
			enabled = true,
		},
	},
}
