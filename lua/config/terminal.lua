-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

local M = {}

local term_buf = nil

local group = vim.api.nvim_create_augroup("FloatTerm", { clear = true })

local function open_win(buf)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "single",
	})

	local function close_win()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		return true
	end

	vim.api.nvim_clear_autocmds({ group = group })

	vim.api.nvim_create_autocmd("WinLeave", {
		group = group,
		buffer = buf,
		callback = close_win,
	})

	vim.api.nvim_create_autocmd("TabNew", {
		group = group,
		callback = close_win,
	})

	vim.cmd("startinsert")
end

local function find_term_win()
	if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
		return nil
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == term_buf then
			return win
		end
	end
	return nil
end

function M.open()
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		local win = find_term_win()
		if win then
			local win_tab = vim.api.nvim_win_get_tabpage(win)
			local cur_tab = vim.api.nvim_get_current_tabpage()
			if win_tab == cur_tab then
				vim.api.nvim_set_current_win(win)
				vim.cmd("startinsert")
				return
			end
			vim.api.nvim_win_close(win, true)
		end
		open_win(term_buf)
		return
	end

	local file = vim.fn.expand("%:p")
	term_buf = vim.api.nvim_create_buf(false, true)

	open_win(term_buf)

	vim.fn.termopen(vim.o.shell, {
		env = {
			F = file,
			EDITOR = vim.v.progpath,
		},
		on_exit = function()
			vim.schedule(function()
				if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
					vim.api.nvim_buf_delete(term_buf, { force = true })
				end
				term_buf = nil
			end)
		end,
	})

	vim.cmd("startinsert")
end

function M.close()
	local win = find_term_win()
	if win then
		vim.api.nvim_win_close(win, true)
	end
end

return M
