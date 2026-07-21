-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- AI-usage disclosure: configuration of C-p for blink.cmp written by an AI model

local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

local on_attach = function(client, bufnr)
	-- Disable syntax highlighting as Treesitter provides it already and is faster
	client.server_capabilities.semanticTokensProvider = nil
end

-- This function is adapted from code made by Konstantin Gorodinskiy, Copyright 2012-2023, MIT license
-- https://github.com/gko/vimio
function lsp_binary_exists(server)
	if not (vim.lsp.config[server] and type(vim.lsp.config[server].cmd) == "table" and #vim.lsp.config[server].cmd >= 1) then
		return false
	end
	return vim.fn.executable(vim.lsp.config[server].cmd[1]) == 1
end

local servers = {
	['bashls'] = {},
	['biome'] = {
		cmd = { 'biome', 'lsp-proxy' },
	},
	['cssls'] = {
		cmd = { 'vscode-css-language-server', '--stdio' },
	},
	['clangd'] = {},
	['denols'] = {},
	['eslint'] = {
		cmd = { 'vscode-eslint-language-server', '--stdio' },
	},
	['gopls'] = {},
	['html'] = {
		cmd = { 'vscode-html-language-server', '--stdio' },
	},
	['jsonls'] = {
		cmd = { 'vscode-json-language-server', '--stdio' },
	},
	['rubocop'] = {},
	['ruff'] = {},
	['terraformls'] = {},
	['tinymist'] = {},
	['yamlls'] = {
		cmd = { 'yaml-language-server', '--stdio' },
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
	['zls'] = {},
}
for server, options in pairs(servers) do
	if vim.lsp.config[server] then
		options.on_attach = on_attach
		options.capabilities = require('blink-cmp').get_lsp_capabilities(options.capabilities)
		vim.lsp.config(server, options)
		if lsp_binary_exists(server) then
			vim.lsp.enable(server)
		end
	end
end

require("blink-cmp").setup{
	cmdline = {
		enabled = false,
	},
	completion = {
		keyword = {
			range = 'full',
		},
	},
	keymap = {
		preset = 'none',
		['<C-Up>'] = { 'select_prev', 'fallback' },
		['<C-Down>'] = { 'select_next', 'fallback' },
		['<C-Enter>'] = { 'select_and_accept', 'fallback' },
		['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
		['<C-c>'] = { 'hide', 'fallback' },
		['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
		['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
		['<Tab>'] = { 'snippet_forward', 'fallback' },
		['<S-Tab>'] = { 'snippet_backward', 'fallback' },
		['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
		['<C-p>'] = {
			-- replace native autocompletion with blink.cmp with only buffer provider
			function(cmp)
				local ctx = cmp.get_context()
				local buffer_only = ctx and #ctx.providers == 1 and ctx.providers[1] == 'buffer'
				if cmp.is_menu_visible() and buffer_only then
					return cmp.select_next({ auto_insert = true })
				end
				return cmp.show({
					providers = { 'buffer' },
					initial_selected_item_idx = 1,
				})
			end
		},
		['<C-n>'] = { 'select_prev' },
	},
	signature = {
		enabled = true,
	},
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},
}
