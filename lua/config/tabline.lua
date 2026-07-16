-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- AI-usage disclosure: this file was written by an AI model

local M = {}

local function define_highlights()
	local function get(name)
		return vim.api.nvim_get_hl(0, { name = name, link = false })
	end

	local palette = require("catppuccin.palettes").get_palette()

	local fgs = {
		Modified = palette.yellow,
		GitStaged = palette.green,
		GitPartial = palette.peach,
		GitDirty = palette.maroon,
		GitConflict = palette.red,
		GitClean = palette.lavender,
		GitIgnored = false,
	}

	local title = get("Title")
	local tabline = get("TabLine")
	local tabline_sel = get("TabLineSel")

	tabline_sel.bg = palette.surface0
	vim.api.nvim_set_hl(0, "TabLineSel", tabline_sel)

	vim.api.nvim_set_hl(0, "TabLineWin",
		vim.tbl_extend("force", title, { bg = tabline.bg }))
	vim.api.nvim_set_hl(0, "TabLineWinSel",
		vim.tbl_extend("force", title, { bg = tabline_sel.bg }))
	for name, fg in pairs(fgs) do
		vim.api.nvim_set_hl(0, "TabLine" .. name,
			vim.tbl_extend("force", tabline, fg and { fg = fg } or {}))
		vim.api.nvim_set_hl(0, "TabLine" .. name .. "Sel",
			vim.tbl_extend("force", tabline_sel, fg and { fg = fg } or {}))
	end
end

local git_status = {}
local git_generation = {}
local git_pending = {}

local conflicts = {
	["DD"] = true, ["AU"] = true, ["UD"] = true, ["UA"] = true,
	["DU"] = true, ["AA"] = true, ["UU"] = true,
}

-- `git status --porcelain` XY pair to highlight suffix
local function classify(xy)
	if xy == nil then
		return "GitClean"
	elseif xy == "!!" then
		return "GitIgnored"
	elseif xy == "??" then
		return "GitDirty"
	elseif conflicts[xy] then
		return "GitConflict"
	end
	local staged = xy:sub(1, 1) ~= " "
	local dirty = xy:sub(2, 2) ~= " "
	if staged and dirty then
		return "GitPartial"
	elseif staged then
		return "GitStaged"
	end
	return "GitDirty"
end

local function git_refresh(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" or vim.bo[buf].buftype ~= "" or name:match("^%w+://") then
		git_status[buf] = "none"
		return
	end

	git_generation[buf] = (git_generation[buf] or 0) + 1
	local generation = git_generation[buf]
	git_pending[buf] = true

	local ok = pcall(vim.system,
		{ "git", "status", "--porcelain", "--ignored", "--", name },
		{ cwd = vim.fs.dirname(name), text = true },
		vim.schedule_wrap(function(out)
			if git_generation[buf] ~= generation then
				return -- superseded by a newer refresh
			end
			git_pending[buf] = nil
			local status = "GitIgnored"
			if out.code == 0 then
				status = classify((out.stdout or ""):match("^(..)"))
			end
			if git_status[buf] ~= status then
				git_status[buf] = status
				vim.cmd.redrawtabline()
			else
				git_status[buf] = status
			end
		end))
	if not ok then
		git_pending[buf] = nil
		git_status[buf] = "none"
	end
end

local function git_refresh_all()
	for buf in pairs(git_status) do
		git_refresh(buf)
	end
end

local function buf_label(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" then
		local buftype = vim.bo[buf].buftype
		if buftype == "quickfix" then
			return "[Quickfix List]"
		elseif buftype == "prompt" then
			return "[Prompt]"
		end
		return "[No Name]"
	end
	if name:match("^%w+://") then
		return name
	end
	return vim.fn.fnamemodify(name, ":~:.")
end

local ellipsis = "…"

local function prefix_fit(s, room)
	while s ~= "" and vim.fn.strwidth(s) > room do
		s = vim.fn.strcharpart(s, 0, vim.fn.strchars(s) - 1)
	end
	return s
end

local function shorten_filename(name, room)
	if vim.fn.strwidth(name) <= room then
		return name
	end
	local stem, ext = name:match("^(.+)(%.[^.]+)$")
	if not stem then
		stem, ext = name, ""
	end
	local avail = room - 1 - vim.fn.strwidth(ext)
	if avail < 1 then
		return prefix_fit(name, room - 1) .. ellipsis
	end
	return prefix_fit(stem, avail) .. ellipsis .. ext
end

local function shorten_dir(comp)
	return vim.fn.strcharpart(comp, 0, comp:sub(1, 1) == "." and 2 or 1)
end

local function fit(name, room)
	if vim.fn.strwidth(name) <= room then
		return name
	end
	if not name:find("/") or name:match("^%w+://") then
		return shorten_filename(name, room)
	end

	local comps = vim.split(name, "/", { plain = true })
	for i = 1, #comps - 1 do
		comps[i] = shorten_dir(comps[i])
		name = table.concat(comps, "/")
		if vim.fn.strwidth(name) <= room then
			return name
		end
	end

	local fname = comps[#comps]
	if 2 + vim.fn.strwidth(fname) <= room then
		return ellipsis .. "/" .. fname
	end
	local ext = fname:match("%.[^.]+$") or ""
	if room - 3 - vim.fn.strwidth(ext) >= 1 then
		return ellipsis .. "/" .. shorten_filename(fname, room - 2)
	end
	return shorten_filename(fname, room)
end

local first_visible = 1

function M.render()
	local tabpages = vim.api.nvim_list_tabpages()
	local current = vim.api.nvim_get_current_tabpage()

	local desired = math.min(#tabpages,
		math.max(1, math.floor(vim.o.columns / 12)))
	local tabwidth = math.floor(vim.o.columns / desired)
	if tabwidth < 12 then
		tabwidth = 12
	elseif tabwidth > 30 then
		tabwidth = 30
	end

	local labels = {}
	local current_index = 1
	for i, tabpage in ipairs(tabpages) do
		local wincount = 0
		local modified = false
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
			if vim.api.nvim_win_get_config(win).relative == "" then
				wincount = wincount + 1
				modified = modified
					or vim.bo[vim.api.nvim_win_get_buf(win)].modified
			end
		end

		local buf = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tabpage))

		local suffix
		if modified then
			suffix = "Modified"
		else
			if git_status[buf] == nil and not git_pending[buf] then
				git_refresh(buf)
			end
			local status = git_status[buf]
			if status ~= nil and status ~= "none" then
				suffix = status
			end
		end

		local sel = tabpage == current
		if sel then
			current_index = i
		end
		local hl = "%#TabLine" .. (suffix or "") .. (sel and "Sel" or "") .. "#"

		local prefix = ""
		if wincount > 1 then
			prefix = (sel and "%#TabLineWinSel#" or "%#TabLineWin#")
				.. wincount .. hl .. " "
		end
		local prefix_width = wincount > 1 and #tostring(wincount) + 1 or 0

		local raw = buf_label(buf)
		local name = fit(raw, tabwidth - 2 - prefix_width)

		labels[i] = {
			hl = hl,
			prefix = prefix,
			raw = raw,
			name = name,
			width = 2 + prefix_width + vim.fn.strwidth(name),
		}
	end

	local counter = " " .. #labels .. " "

	local function last_visible(first)
		local avail = vim.o.columns - #counter - (first > 1 and 1 or 0)
		local width = 0
		for i = first, #labels do
			width = width + labels[i].width
		end
		if width <= avail then
			return #labels
		end
		avail = avail - 1 -- room for the ">" indicator
		width = 0
		for i = first, #labels do
			width = width + labels[i].width
			if width > avail then
				return i - 1
			end
		end
		return #labels
	end

	if last_visible(1) == #labels then
		first_visible = 1 -- everything fits
	else
		if first_visible > current_index then
			first_visible = current_index
		end
		while first_visible < current_index
			and last_visible(first_visible) < current_index do
			first_visible = first_visible + 1
		end
	end
	local last = math.max(last_visible(first_visible), current_index)

	local slack = vim.o.columns - #counter
		- (first_visible > 1 and 1 or 0) - (last < #labels and 1 or 0)
	for i = first_visible, last do
		slack = slack - labels[i].width
	end
	for i = first_visible, last do
		if slack <= 0 then
			break
		end
		local label = labels[i]
		local width = vim.fn.strwidth(label.name)
		if vim.fn.strwidth(label.raw) > width then
			label.name = fit(label.raw, width + slack)
			local gain = vim.fn.strwidth(label.name) - width
			label.width = label.width + gain
			slack = slack - gain
		end
	end

	local parts = {}
	if first_visible > 1 then
		parts[#parts + 1] = "%#TabLine#<"
	end
	for i = first_visible, last do
		local label = labels[i]
		parts[#parts + 1] = label.hl .. "%" .. i .. "T"
			.. " " .. label.prefix .. label.name:gsub("%%", "%%%%") .. " "
	end
	parts[#parts + 1] = "%T%#TabLineFill#%="
	if last < #labels then
		parts[#parts + 1] = "%#TabLine#>"
	end
	parts[#parts + 1] = "%#TabLine#" .. counter
	return table.concat(parts)
end

function M.setup()
	define_highlights()

	local group = vim.api.nvim_create_augroup("config.tabline", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = define_highlights,
	})

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufFilePost" }, {
		group = group,
		callback = function(args)
			git_refresh(args.buf)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "GitSignsUpdate",
		callback = function(args)
			local buf = args.data and args.data.buffer
			if buf then
				git_refresh(buf)
			end
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "GitSignsChanged",
		callback = git_refresh_all,
	})
	vim.api.nvim_create_autocmd({ "VimResume", "FocusGained", "TermLeave" }, {
		group = group,
		callback = git_refresh_all,
	})
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = group,
		callback = function(args)
			git_status[args.buf] = nil
			git_generation[args.buf] = nil
			git_pending[args.buf] = nil
		end,
	})

	vim.o.tabline = "%!v:lua.require'config.tabline'.render()"
end

return M
