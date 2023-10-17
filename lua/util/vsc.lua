local M = {}

---@param direction "Up"|"Down"
function M.move_visual_selection(direction)
	local cursor_line = vim.fn.line("v")
	local cursor_start_line = vim.fn.line(".")
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
	vim.fn.VSCodeNotifyRange("editor.action.moveLines" .. direction .. "Action", start_line, end_line, 1)
	if direction == "Up" then
		if end_line > 1 then
			start_line = start_line - 1
			end_line = end_line - 1
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
			vim.cmd("normal!" .. start_line .. "GV" .. end_line .. "G")
		end
	else -- == "Down"
		if end_line < vim.api.nvim_buf_line_count(0) then
			start_line = start_line + 1
			end_line = end_line + 1
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
			vim.cmd("normal!" .. start_line .. "GV" .. end_line .. "G")
		end
	end
end

---@param direction "Up"|"Down"
function M.move_line(direction)
	M.move_visual_selection(direction)
	local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
	vim.api.nvim_feedkeys(esc, "x", false)
end

function M.action_marked(command)
	require("vscode-neovim").action(command)
	vim.cmd("normal! m'")
end

function M.go_to_definition_marked(str)
	if vim.b.vscode_controlled then
		M.action_marked('editor.action.' .. str)
	end
	-- Allow to function in help files
	vim.cmd("normal! <C-]>")
end

---@param call_type "action" | "call"
---@param cmd string
local function vscode_insert_selection(call_type, cmd)
	local vscode = require("vscode-neovim")
	local mode = vim.fn.mode()
	local sel_start = vim.fn.getpos("v")
	local sel_end = vim.fn.getpos(".")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true) .. "a", "v", false)
	vim.defer_fn(function()
		if mode == "V" then
			vscode[call_type](cmd,
				{ range = { sel_start[2] - 1, sel_end[2] - 1 }, restore_selection = false })
		else
			vscode[call_type](cmd, {
				range = { sel_start[2] - 1, sel_start[3] - 1, sel_end[2] - 1, sel_end[3] },
				restore_selection = false
			})
		end
	end, 60)
end

---@param cmd string
---@param ... unknown VSCode command arguments
function M.vscode_action_insert_selection(cmd, ...)
	return vscode_insert_selection("action", cmd)
end

---@param cmd string
---@param ... unknown VSCode command arguments
function M.vscode_call_insert_selection(cmd, ...)
	return vscode_insert_selection("call", cmd)
end

return M
