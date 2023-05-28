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
	vim.cmd("call VSCodeCallRange('editor.action.moveLines" ..
		direction .. "Action'," .. start_line .. "," .. end_line .. ",1)")
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
	vim.fn["VSCodeNotify"](command)
	vim.cmd("normal! m'")
end

function M.go_to_definition_marked(str)
	if vim.b.vscode_controlled then
		M.notify_marked('editor.action.' .. str)
	end
	-- Allow to function in help files
	vim.cmd("normal! <C-]>")
end

local function fix_visual_pos(start_pos, end_pos)
	if (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) or start_pos[2] > end_pos[2] then
		start_pos[3] = start_pos[3] + 1
	else
		end_pos[3] = end_pos[3] + 1
	end
	return { start_pos, end_pos }
end

---Lua version of the fixed VSCodeNotifyVisual function
---@param cmd string
---@param leave_selection boolean | number
---@param ... unknown VSCode command arguments
function M.vscode_notify_visual(cmd, leave_selection, ...)
	local mode = vim.api.nvim_get_mode().mode
	if mode == 'V' then
		local start_line = vim.fn.line('v')
		local end_line = vim.fn.line('.')
		vim.fn.VSCodeNotifyRange(cmd, start_line, end_line, leave_selection, { ... })
	elseif mode == 'v' or mode == "<C-v>" then
		local start_pos = vim.fn.getpos('v')
		local end_pos = vim.fn.getpos('.')
		start_pos, end_pos = table.unpack(fix_visual_pos(start_pos, end_pos))
		vim.fn.VSCodeNotifyRangePos(cmd, start_pos[2], end_pos[2], start_pos[3], end_pos[3], leave_selection, { ... })
	else
		vim.fn.VSCodeNotify(cmd, { ... })
	end
end

return M
