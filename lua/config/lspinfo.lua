-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- AI-usage disclosure: this file was written by an AI model

local M = {}

local group = vim.api.nvim_create_augroup("LspInfo", { clear = true })
local ns = vim.api.nvim_create_namespace("LspInfo")

-- Highlight groups (linked to standard groups so they follow the colorscheme).
local HL = {
	buffer   = "Title",
	header   = "Title",
	active   = "DiagnosticOk",
	other    = "DiagnosticInfo",
	inactive = "DiagnosticWarn",
	name     = "Function",
	bullet   = "Special",
	label    = "Comment",
	value    = "Normal",
	warn     = "DiagnosticError",
	none     = "Comment",
}

--- Each entry is a line: a list of { text, hl } segments.
--- @param lines table
--- @param segments table
local function add(lines, segments)
	table.insert(lines, segments)
end

local function field(pad, label, value)
	return {
		{ pad .. "  " },
		{ label .. ": ", HL.label },
		{ value, HL.value },
	}
end

local function client_entry(lines, client, indent)
	local pad = string.rep(" ", indent)
	add(lines, {
		{ pad },
		{ "* ", HL.bullet },
		{ client.name, HL.name },
		{ " (id: " .. client.id .. ")", HL.label },
	})
	if client.root_dir then
		add(lines, field(pad, "root", vim.fn.fnamemodify(client.root_dir, ":~")))
	end
	local fts = client.config and client.config.filetypes
	if fts and #fts > 0 then
		add(lines, field(pad, "filetypes", table.concat(fts, ", ")))
	end
	local attached = {}
	for buf in pairs(client.attached_buffers or {}) do
		if vim.api.nvim_buf_is_valid(buf) then
			table.insert(attached, tostring(buf))
		end
	end
	if #attached > 0 then
		add(lines, field(pad, "buffers", table.concat(attached, ", ")))
	end
end

local function config_entry(lines, name, indent)
	local pad = string.rep(" ", indent)
	add(lines, {
		{ pad },
		{ "* ", HL.bullet },
		{ name, HL.name },
	})
	local config = vim.lsp.config[name]
	local fts = config and config.filetypes
	if fts and #fts > 0 then
		add(lines, field(pad, "filetypes", table.concat(fts, ", ")))
	end
	if config and type(config.cmd) == "table" then
		local exe = config.cmd[1]
		if exe and vim.fn.executable(exe) == 0 then
			add(lines, {
				{ pad .. "  " },
				{ "not installed: " .. exe, HL.warn },
			})
		end
	end
end

local function build(buf)
	local lines = {}

	local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" then
		name = "[No Name]"
	end
	add(lines, {
		{ "Buffer " .. buf .. ": ", HL.label },
		{ name, HL.buffer },
	})
	add(lines, {
		{ "Filetype: ", HL.label },
		{ ft ~= "" and ft or "(none)", HL.value },
	})
	add(lines, {})

	local active = vim.lsp.get_clients({ bufnr = buf })

	local active_names = {}
	for _, c in ipairs(active) do
		active_names[c.name] = true
	end

	add(lines, { { "Active on this buffer", HL.active } })
	if #active == 0 then
		add(lines, { { "  (none)", HL.none } })
	else
		for _, c in ipairs(active) do
			client_entry(lines, c, 0)
		end
	end
	add(lines, {})

	-- Running clients attached to other buffers (not this one).
	local other = {}
	for _, c in ipairs(vim.lsp.get_clients()) do
		if not active_names[c.name] then
			table.insert(other, c)
			active_names[c.name] = true
		end
	end

	add(lines, { { "Active on other buffers", HL.other } })
	if #other == 0 then
		add(lines, { { "  (none)", HL.none } })
	else
		for _, c in ipairs(other) do
			client_entry(lines, c, 0)
		end
	end
	add(lines, {})

	-- Enabled configs that are not running at all.
	local configured = {}
	for cfg_name in pairs(vim.lsp._enabled_configs or {}) do
		if not active_names[cfg_name] then
			table.insert(configured, cfg_name)
		end
	end
	table.sort(configured)

	add(lines, { { "Configured but not active", HL.inactive } })
	if #configured == 0 then
		add(lines, { { "  (none)", HL.none } })
	else
		for _, cfg_name in ipairs(configured) do
			config_entry(lines, cfg_name, 0)
		end
	end

	return lines
end

--- Render segmented lines into a buffer with highlights.
--- @param buf integer target buffer
--- @param lines table list of segment-lists
local function render(buf, lines)
	local text = {}
	for _, segments in ipairs(lines) do
		local parts = {}
		for _, seg in ipairs(segments) do
			table.insert(parts, seg[1])
		end
		table.insert(text, table.concat(parts))
	end

	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	for row, segments in ipairs(lines) do
		local col = 0
		for _, seg in ipairs(segments) do
			local len = #seg[1]
			if seg[2] and len > 0 then
				vim.api.nvim_buf_set_extmark(buf, ns, row - 1, col, {
					end_col = col + len,
					hl_group = seg[2],
				})
			end
			col = col + len
		end
	end

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

function M.open(buf)
	buf = buf or vim.api.nvim_get_current_buf()

	local lines = build(buf)

	local info_buf = vim.api.nvim_create_buf(false, true)
	render(info_buf, lines)

	local width = math.min(80, math.floor(vim.o.columns * 0.6))
	local height = math.min(#lines + 1, math.floor(vim.o.lines * 0.6))

	local win = vim.api.nvim_open_win(info_buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "single",
		title = " LSP Info ",
		title_pos = "center",
	})

	local function close_win()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		if vim.api.nvim_buf_is_valid(info_buf) then
			vim.api.nvim_buf_delete(info_buf, { force = true })
		end
		return true
	end

	vim.api.nvim_clear_autocmds({ group = group })

	vim.api.nvim_create_autocmd("WinLeave", {
		group = group,
		buffer = info_buf,
		callback = close_win,
	})

	vim.api.nvim_create_autocmd("TabNew", {
		group = group,
		callback = close_win,
	})

	vim.keymap.set("n", "q", close_win, { buffer = info_buf })
	vim.keymap.set("n", "<Esc>", close_win, { buffer = info_buf })
end

return M
