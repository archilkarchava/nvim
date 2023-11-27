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
	require("vscode-neovim").action("editor.action.moveLines" .. direction .. "Action",
		{
			range = { direction == "Down" and start_line - 1 or start_line, end_line - 1 },
			restore_selection = false,
			callback = function()
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
		})
end

---@param direction "Up"|"Down"
function M.move_line(direction)
	M.move_visual_selection(direction)
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "x", false)
end

---- Run an action asynchronously
---@param name string The action name, generally a vscode command
---@param opts? table Optional options table, all fields are optional
---            - args: (table) Optional arguments for the action
---            - range: (table) Specific range for the action. In visual mode, this parameter is generally not needed.
---                     Three formats supported (All values are 0-indexed):
---                        - [start_line, end_line]
---                        - [start_line, start_character, end_line, end_character]
---                        - {start = { line = start_line , character = start_character}, end = { line = end_line , character = end_character}}
---            - restore_selection: (boolean) Whether to preserve the current selection, only valid when `range` is specified. Defaults to `true`
---            - callback: (function(err: string|nil, ret: any))
---                        Optional callback function to handle the action result.
---                        The first argument is the error message, and the second is the result.
---                        If no callback is provided, any error message will be shown as a notification in VSCode.
---            - count: (number) How many times to repeat the action. The vim.v.count1 is used by default.
function M.action(name, opts)
	opts = opts or {}
	local count = opts.count or vim.v.count1
	local vscode = require("vscode-neovim")
	local commands = {}
	for i = 1, count do
		commands[i] = { command = name, args = opts.args }
	end
	if count == 1 then
		return vscode.action(name, {
			args = opts.args,
			range = opts.range,
			restore_selection = opts.restore_selection,
			callback = opts.callback,
		})
	end
	return vscode.action("runCommands", {
		args = { { commands = commands, } },
		range = opts.range,
		restore_selection = opts.restore_selection,
		callback = opts.callback,
	})
end

function M.action_marked(command)
	M.action(command, {
		---@param err string|nil
		callback = function(err)
			if err then
				return
			end
			vim.cmd("normal! m'")
		end
	})
end

function M.go_to_definition_marked(str)
	if vim.b.vscode_controlled then
		M.action_marked("editor.action." .. str)
	end
	-- Allow to function in help files
	vim.cmd("normal! <C-]>")
end

---@param table table
local function decrementTableItemsBy1(table)
	for i in ipairs(table) do
		table[i] = table[i] - 1
	end
	return table
end

local function fixVisualPos(startPos, endPos)
	if (startPos[2] == endPos[2] and startPos[3] > endPos[3]) or startPos[2] > endPos[2] then
		startPos[3] = startPos[3] + 1
	else
		endPos[3] = endPos[3] + 1
	end
	return { startPos, endPos }
end

---@param name string The action name, generally a vscode command
---@param opts? table Optional options table, all fields are optional
---            - args: (table) Optional arguments for the action
---            - callback: (function(err: string|nil, ret: any))
---                        Optional callback function to handle the action result.
---                        The first argument is the error message, and the second is the result.
---                        If no callback is provided, any error message will be shown as a notification in VSCode.
---            - count: (number) How many times to repeat the action. The vim.v.count1 is used by default.
function M.action_insert_selection(name, opts)
	opts = opts or {}
	local count = opts.count or vim.v.count1
	local mode = vim.fn.mode()
	local sel_start = vim.fn.getpos("v")
	local sel_end = vim.fn.getpos(".")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true) .. "a", "m", false)
	sel_start = decrementTableItemsBy1(sel_start)
	sel_end = decrementTableItemsBy1(sel_end)
	local range;
	if mode == "V" then
		range = sel_end[2] > sel_start[2] and { sel_start[2], sel_end[2] } or
				{ sel_end[2], sel_start[2] }
	else
		sel_start, sel_end = table.unpack(fixVisualPos(sel_start, sel_end))
		range = { sel_start[2], sel_start[3], sel_end[2], sel_end[3] }
	end
	return M.action(name, {
		range = range,
		restore_selection = false,
		args = opts.args,
		callback = opts.callback,
		count = count
	})
end

return M
