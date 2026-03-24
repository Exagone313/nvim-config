# Neovim configuration

This repository hosts my Neovim configuration.

## Configuration files

Lua configuration files are loaded in this order (see [init.lua](./init.lua)):
* [vim.lua](./lua/config/vim.lua): general Vim options
* [colors.lua](./lua/config/colors.lua): colorscheme configuration
* [treesitter.lua](./lua/config/treesitter.lua): Tree-sitter configuration
* [lsp.lua](./lua/config/lsp.lua): configuration for Language Server Protocol and completion
* [above.lua](./lua/config/above.lua): configuration for plugins that are displayed above buffer
* [top.lua](./lua/config/top.lua): configuration for tabs and plugins that are displayed on top of the buffer
* [bottom.lua](./lua/config/bottom.lua): configuration for plugins that are displayed below the buffer (like statusline)
* [buffer.lua](./lua/config/buffer.lua): configuration for buffer mapping and plugins that interact with the buffer

## Plugins

### Colorscheme

* [Catppuccin](https://github.com/catppuccin/nvim): Catppuccin colorscheme

### Tree-sitter

* [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter): installs Tree-sitter parsers and manages their configuration

### LSP

* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig): configuration for many LSP servers
* [Blink Completion](https://github.com/saghen/blink.cmp): completion with LSP integration

### Above

* [nvim-notify](https://github.com/rcarriga/nvim-notify): for displaying notifications in pop-ups
* [Noice](https://github.com/folke/noice.nvim): enter commands and searches from a pop-up in the middle of the editor
* [Which Key](https://github.com/folke/which-key.nvim): pop-up for listing key maps as I type
* [Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim): file manager, replaces netrw, configured to open in a pop-up
* [Fzf-lua](https://github.com/ibhagwan/fzf-lua): fuzzy finder

### Top

* [Dropbar](https://github.com/Bekaboo/dropbar.nvim): breadcrumbs for source code context

### Bottom

* [lualine](https://github.com/nvim-lualine/lualine.nvim): improved statusline

### Buffer

* [Diffview](https://github.com/sindrets/diffview.nvim): Git diff viewer
* [Gitsigns](https://github.com/lewis6991/gitsigns.nvim): show lines modified from Git on the left of the buffer
* [Indent Blankline](https://github.com/lukas-reineke/indent-blankline.nvim): show indent levels in buffer
* [Mini Trailspace](https://github.com/nvim-mini/mini.nvim/blob/main/readmes/mini-trailspace.md): show trailing whitespaces
* [guess-indent](https://github.com/NMAC427/guess-indent.nvim) ([fork](https://github.com/Exagone313/guess-indent.nvim)): detect file indentation style
* [Conform](https://github.com/stevearc/conform.nvim): formatter manager

## License

Unless otherwise stated, software in this repository is released under the 3-Clause BSD License (see `COPYING`).
