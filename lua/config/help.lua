-- SPDX-FileCopyrightText: 2026 Elouan Martinet <exa@elou.world>
-- SPDX-License-Identifier: BSD-3-Clause

-- AI-usage disclosure: this file was written by an AI model

local M = {}

-- Prompt for a help page name (with :help-style autocompletion) and open it
-- in a new tab.
function M.open()
	local ok, topic = pcall(vim.fn.input, {
		prompt = "Help: ",
		completion = "help",
	})

	if not ok or topic == nil then
		return
	end

	topic = vim.trim(topic)
	if topic == "" then
		return
	end

	local cmd_ok, err = pcall(vim.cmd, "tab help " .. vim.fn.fnameescape(topic))
	if not cmd_ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end

return M
