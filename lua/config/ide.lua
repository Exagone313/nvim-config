-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- Per-tab "IDE mode": when enabled on a tabpage, neo-tree is shown as a side
-- panel on that tab and a few related behaviors change (see lua/config/above.lua).
-- Other tabs are unaffected.

local M = {}

-- enabled[tabid] = true when IDE mode is on for that tab
M.enabled = {}

-- Hooks fired when IDE mode is toggled on/off for a tab. Each hook receives
-- the tabid. Append to these lists from elsewhere to extend IDE mode.
M.on_enable  = {}
M.on_disable = {}

local function tab(tabid)
	if tabid == nil or tabid == 0 then
		return vim.api.nvim_get_current_tabpage()
	end
	return tabid
end

---@param tabid integer? defaults to current tab
function M.is_enabled(tabid)
	return M.enabled[tab(tabid)] == true
end

local function open_side_tree()
	require("neo-tree.command").execute({
		source   = "filesystem",
		action   = "show",      -- show without stealing focus from the current file
		position = "left",
		reveal   = true,
	})
end

local function close_side_tree()
	-- close only the "left" position of the filesystem source on this tab.
	-- Float-position neo-tree on this tab (if any) is left alone.
	require("neo-tree.command").execute({
		action   = "close",
		source   = "filesystem",
		position = "left",
	})
end

---@param tabid integer? defaults to current tab
function M.enable(tabid)
	local id = tab(tabid)
	if M.enabled[id] then
		return
	end
	M.enabled[id] = true
	open_side_tree()
	for _, hook in ipairs(M.on_enable) do
		pcall(hook, id)
	end
end

---@param tabid integer? defaults to current tab
function M.disable(tabid)
	local id = tab(tabid)
	if not M.enabled[id] then
		return
	end
	M.enabled[id] = nil
	close_side_tree()
	for _, hook in ipairs(M.on_disable) do
		pcall(hook, id)
	end
end

---@param tabid integer? defaults to current tab
function M.toggle(tabid)
	if M.is_enabled(tabid) then
		M.disable(tabid)
	else
		M.enable(tabid)
	end
end

-- Forget state for tabs that no longer exist.
vim.api.nvim_create_autocmd("TabClosed", {
	callback = function(args)
		-- args.file contains the tab number as a string (1-indexed display number),
		-- not the tabid; iterate and prune any stale ids.
		local alive = {}
		for _, id in ipairs(vim.api.nvim_list_tabpages()) do
			alive[id] = true
		end
		for id in pairs(M.enabled) do
			if not alive[id] then
				M.enabled[id] = nil
			end
		end
	end,
})

return M
