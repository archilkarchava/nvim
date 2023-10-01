local M = {}

---@param direction "Up"|"Down"
function M.move_visual_selection(direction)
	local cursor_line = vim.fn.line('v')
	local cursor_start_line = vim.fn.line('.')
	local start_line = cursor_line
	local end_line = cursor_start_line
	if direction == "Up" then
		if start_line < end_line then
			local tmp = start_line
			start_line = end_line
			end_line = tmp
		end
	else -- == "Down"
		if start_line > end_line then
			local tmp = start_line
			start_line = end_line
			end_line = tmp
		end
	end
	vim.fn.VSCodeCallRange("editor.action.moveLines" .. direction .. "Action", start_line, end_line, 1)
	if direction == "Up" then
		if end_line > 1 then
			start_line = start_line - 1
			end_line = end_line - 1
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'x', true)
			vim.cmd("normal!" .. start_line .. "GV" .. end_line .. "G")
		end
	else -- == "Down"
		if end_line < vim.api.nvim_buf_line_count(0) then
			start_line = start_line + 1
			end_line = end_line + 1
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'x', true)
			vim.cmd("normal!" .. start_line .. "GV" .. end_line .. "G")
		end
	end
end

---@param direction "Up"|"Down"
function M.move_line(direction)
	M.move_visual_selection(direction)
	local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
	vim.api.nvim_feedkeys(esc, 'x', false)
end

function M.notify_marked(command)
	require("vscode-neovim").notify(command)
	vim.cmd("normal! m'")
end

function M.go_to_definition_marked(str)
	if vim.b.vscode_controlled then
		M.notify_marked('editor.action.' .. str)
	end
	-- Allow to function in help files
	vim.cmd("normal! <C-]>")
end

---@param call_type 'notify' | 'call'
---@param cmd string
local function vscode_insert_selection(call_type, cmd)
	local visual_method = call_type == 'notify' and 'notify_range_pos' or 'call_range_pos'
	local visual_line_method = call_type == 'notify' and 'notify_range' or 'call_range'
	local mode = vim.fn.mode()
	local sel_start = vim.fn.getpos("v")
	local sel_end = vim.fn.getpos(".")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true) .. "a", "v", false)
	vim.defer_fn(function()
		if mode == 'V' then
			require("vscode-neovim")[visual_line_method](cmd, sel_start[2], sel_end[2], true)
		else
			require("vscode-neovim")[visual_method](cmd, sel_start[2], sel_end[2],
				sel_start[3],
				sel_end[3], true)
		end
	end, 50)
end

---@param cmd string
---@param ... unknown VSCode command arguments
function M.vscode_notify_insert_selection(cmd, ...)
	return vscode_insert_selection('notify', cmd)
end

---@param cmd string
---@param ... unknown VSCode command arguments
function M.vscode_call_insert_selection(cmd, ...)
	return vscode_insert_selection('call', cmd)
end

return M
