local Util = require("util")
local vsc = require("util.vsc")

local function map(mode, lhs, rhs, opts)
	local keys = require("lazy.core.handler").handlers.keys
	-- do not create the keymap if a lazy keys handler exists
	if not keys.active[keys.parse({ lhs, mode = mode }).id] then
		opts = opts or {}
		opts.silent = opts.silent ~= false
		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

local opts = { noremap = true, silent = true }
local expr_opts = { expr = true, noremap = true, silent = true }

---Generates OS-specific keymaps
---@param key_bind string
---@return string
local function ctrl_cmd_lhs(key_bind)
	local default_primary_mod_key = Util.is_mac() and "D" or "C"
	return "<" .. default_primary_mod_key .. "-" .. key_bind .. ">"
end

-- Command mode mappings
map("c", "<C-j>", "<Down>", { noremap = true })
map("c", "<C-k>", "<Up>", { noremap = true })

map("n", "Q", "<nop>", { noremap = true })

map("", "x", '"_x', { noremap = true })
map("", "X", '"_X', { noremap = true })
map("i", "<D-v>", "<C-r><C-o>*<CR>", opts)

-- Delete lines
map("n", "<D-K>", '"_dd', opts)
map("x", "<D-K>", function()
	if vim.fn.mode() == "V" then
		return '"_d'
	end
	return 'V"_d'
end, expr_opts)

if vim.g.vscode then
	---@param direction "up" | "down"
	local function move_wrapped(direction)
		return vsc.call("cursorMove",
			{ args = { { to = direction, by = "wrappedLine", value = vim.v.count1 } }, count = 1 })
	end
	map("v", "gk", function()
		move_wrapped("up")
	end, opts)
	map("v", "gj", function()
		move_wrapped("down")
	end, opts)
end

-- local move_wrapped_opts = { expr = true, silent = true, remap = true }
-- map({ "n" }, "k", "v:count == 0 ? 'gk' : 'k'", move_wrapped_opts)
-- map({ "n" }, "j", "v:count == 0 ? 'gj' : 'j'", move_wrapped_opts)

-- map('', '<Leader>hc', '<Cmd>noh<CR>', { noremap = true, silent = true })

if vim.g.vscode then
	map("n", "<leader>l", function()
		vsc.action("codelens.showLensesInCurrentLine", { count = 1 })
	end, { desc = "Show CodeLens Commands For Current Line" })
else
	map("n", "<leader>l", "<Cmd>:Lazy<CR>", { desc = "Lazy" })
end

if vim.g.vscode then
	-- Comment
	map({ "n", "x", "o" }, "gc", "<Plug>VSCodeCommentary", { remap = true })
	map("n", "gcc", "<Plug>VSCodeCommentaryLine", { remap = true })
	map({ "x", "o" }, ctrl_cmd_lhs("/"), "<Plug>VSCodeCommentary", { remap = true })
	map("n", ctrl_cmd_lhs("/"), "<Plug>VSCodeCommentaryLine", { remap = true })
	map("n", ctrl_cmd_lhs("/"), "<Plug>VSCodeCommentaryLine", { remap = true })
	if Util.is_mac() then
		map({ "x", "n" }, "<C-/>", "<C-/>", { remap = true })
	end

	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("c"),
		function()
			vsc.action("editor.action.addCommentLine")
		end,
		opts
	)
	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("u"),
		function()
			vsc.action("editor.action.removeCommentLine")
		end,
		opts
	)

	map({ "n", "x" }, "<M-A>", function()
		vsc.action("editor.action.blockComment")
	end, opts)
end

if vim.g.vscode then
	map({ "n", "v" }, "<C-h>", function()
		vsc.action("workbench.action.navigateLeft")
	end, opts)
	map({ "n", "v" }, "<C-k>", function()
		vsc.action("workbench.action.navigateUp")
	end, opts)
	map({ "n", "v" }, "<C-l>", function()
		vsc.action("workbench.action.navigateRight")
	end, opts)
	map({ "n", "v" }, "<C-j>", function()
		vsc.action("workbench.action.navigateDown")
	end, opts)
	map({ "n", "v" }, "<C-w><C-k>", function()
		vsc.action("workbench.action.moveEditorToAboveGroup")
	end, opts)
else
	map({ "n", "v" }, "<C-h>", "<C-w>h", opts)
	map({ "n", "v" }, "<C-k>", "<C-w>k", opts)
	map({ "n", "v" }, "<C-l>", "<C-w>l", opts)
	map({ "n", "v" }, "<C-j>", "<C-w>j", opts)
end

-- Scroll
if vim.g.vscode then
	-- Scroll
	---@param direction "up"|"down"
	local function scroll_half_page(direction)
		local vscode_command = direction == "up" and "germanScroll.bertholdUp" or "germanScroll.bertholdDown"
		vsc.action(vscode_command, {
			callback = function()
				vim.cmd("normal zz")
			end
		})
	end

	map({ "n", "v" }, "<C-y>", function()
		vsc.action("germanScroll.arminUp")
	end, opts)
	map({ "n", "v" }, "<C-e>", function()
		vsc.action("germanScroll.arminDown")
	end, opts)
	map({ "n", "v" }, "<C-u>", function()
		scroll_half_page("up")
	end, opts)
	map({ "n", "v" }, "<C-d>", function()
		scroll_half_page("down")
	end, opts)
	map({ "n", "v" }, "<C-b>", function()
		vsc.action("germanScroll.christaUp")
	end, opts)
	map({ "n", "v" }, "<C-f>", function()
		vsc.action("germanScroll.christaDown")
	end, opts)

	map({ "n" }, "zh", function()
		vsc.action("scrollLeft")
	end, opts)

	map({ "n" }, "z<Left>", function()
		vsc.action("scrollLeft")
	end, opts)

	map({ "n" }, "zl", function()
		vsc.action("scrollRight")
	end, opts)

	map({ "n" }, "z<Right>", function()
		vsc.action("scrollRight")
	end, opts)

	map({ "n" }, "zH", function()
		vsc.action("scrollLeft", { count = 10000 })
	end, opts)

	map({ "n" }, "zL", function()
		vsc.action("scrollRight", { count = 10000 })
	end, opts)
else
	map({ "n", "x" }, "<C-d>", "<C-d>zz", opts)
	map({ "n", "x" }, "<C-u>", "<C-u>zz", opts)
end

if vim.g.vscode then
	-- Insert line above / below
	map("n", ctrl_cmd_lhs("Enter"), "o<Esc>", opts)
	map("n", ctrl_cmd_lhs("S-Enter"), "O<Esc>", opts)

	-- o and O

	---@param direction "above" | "below"
	local function insert_line(direction)
		if vim.fn.reg_recording() ~= "" then
			local key = direction == "above" and "O" or "o"
			vim.cmd("normal! " .. key)
			return
		end
		if direction == "below" then
			vsc.call("cursorMove", {
				args = { { to = "down", value = 1 } },
				count = 1
			})
		end
		local count = vim.v.count1
		vim.api.nvim_feedkeys("i", "m", false)
		vsc.action(
			"editor.action.insertLineBefore", {
				callback = function()
					if count > 1 then
						vsc.action("cursorMove", {
							args = { { to = "down", value = count - 1 } },
							callback = function()
								vsc.action("editor.action.insertCursorAbove", {
									count = count - 1
								})
							end,
							count = 1,
						})
					end
				end,
				count = count
			})
	end
	-- map("n", "o", function()
	-- 	insert_line("below")
	-- end, opts)
	-- map("n", "O", function()
	-- 	insert_line("above")
	-- end, opts)

	-- Copy text
	if Util.is_mac() then
		map("n", "<D-c>", "yy", opts)
		map("x", "<D-c>", "ygv<Esc>", opts)
	end

	map("n", ctrl_cmd_lhs("d"), function()
		vim.api.nvim_feedkeys("i", "m", false)
		vsc.action("editor.action.addSelectionToNextFindMatch")
	end, opts)
	map("x", ctrl_cmd_lhs("d"), function()
		vsc.action_insert_selection("editor.action.addSelectionToNextFindMatch")
	end, opts)

	map("n", ctrl_cmd_lhs("l"), "0vj", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("l"), function()
		vsc.action("expandLineSelection")
	end, opts)
	map("n", ctrl_cmd_lhs("t"), function()
		vsc.action("workbench.action.showAllSymbols", { count = 1 })
	end, opts)
	map("x", ctrl_cmd_lhs("t"), function()
		vsc.action("workbench.action.showAllSymbols", {
			callback = function()
				local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
				vim.api.nvim_feedkeys(esc, "m", false)
			end,
			count = 1
		})
	end, opts)
	map("n", ctrl_cmd_lhs("L"), function()
		vim.api.nvim_feedkeys("i", "m", false)
		vsc.action("editor.action.selectHighlights", { count = 1 })
	end, opts)
	map("x", ctrl_cmd_lhs("L"), function()
		vsc.action_insert_selection("editor.action.selectHighlights", { count = 1 })
	end, opts)

	-- Git revert
	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("r"),
		function()
			vsc.action("git.revertSelectedRanges", { count = 1 })
		end,
		opts
	)

	-- Git changes
	map({ "n", "x" }, "]g", function()
		vsc.action("workbench.action.editor.nextChange")
		vsc.action("workbench.action.compareEditor.nextChange")
	end, opts)
	map({ "n", "x" }, "[g", function()
		vsc.action("workbench.action.editor.previousChange")
		vsc.action("workbench.action.compareEditor.previousChange")
	end, opts)

	map({ "n", "v" }, "<Leader>]g", function()
		vsc.action("editor.action.dirtydiff.next")
	end, opts)
	map({ "n", "v" }, "<Leader>[g", function()
		vsc.action("editor.action.dirtydiff.previous")
	end, opts)

	map("n", "<Leader>gC", function()
		vsc.action("merge-conflict.accept.all-current")
	end, opts)
	map("n", "<Leader>gI", function()
		vsc.action("merge-conflict.accept.all-incoming")
	end, opts)
	map("n", "<Leader>gB", function()
		vsc.action("merge-conflict.accept.all-both")
	end, opts)
	map("n", "<Leader>gc", function()
		vsc.action("merge-conflict.accept.current")
	end, opts)
	map("n", "<Leader>gi", function()
		vsc.action("merge-conflict.accept.incoming")
	end, opts)
	map("n", "<Leader>gb", function()
		vsc.action("merge-conflict.accept.both")
	end, opts)
	map("v", "<Leader>ga", function()
		vsc.action("merge-conflict.accept.selection")
	end, opts)
	map({ "n", "v" }, "]x", function()
		vsc.action("merge-conflict.next")
	end, opts)
	map({ "n", "v" }, "[x", function()
		vsc.action("merge-conflict.previous")
	end, opts)
	map({ "n", "v" }, "<Leader>]x", function()
		vsc.action("merge.goToNextUnhandledConflict")
	end, opts)
	map({ "n", "v" }, "<Leader>[x", function()
		vsc.action("merge.goToPreviousUnhandledConflict")
	end, opts)
	map({ "n", "v" }, "]d", function()
		vsc.action("editor.action.marker.next")
	end, opts)
	map({ "n", "v" }, "[d", function()
		vsc.action("editor.action.marker.prev")
	end, opts)
	map("n", "<Leader>]d", function()
		vsc.action("editor.action.marker.nextInFiles")
	end, opts)
	map("n", "<Leader>[d", function()
		vsc.action("editor.action.marker.prevInFiles")
	end, opts)

	---@param direction "next"|"previous"
	local function go_to_breakpoint(direction)
		local vsc = vsc
		local vscode_command = direction == "next" and "editor.debug.action.goToNextBreakpoint" or
				"editor.debug.action.goToPreviousBreakpoint"
		vsc.action(vscode_command, {
			callback = function()
				vsc.action("workbench.action.focusActiveEditorGroup", {
					callback = function()
						local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
						vim.api.nvim_feedkeys(esc .. "^", "m", false)
					end,
					count = 1,
				})
			end,
			count = 1,
		})
	end

	map({ "n", "v" }, "]b", function()
		go_to_breakpoint("next")
	end, opts)

	map({ "n", "v" }, "[b", function()
		go_to_breakpoint("previous")
	end, opts)

	map("n", "<Leader>m", function()
		vsc.action("bookmarks.toggle")
	end, opts)
	map("n", "<Leader>M", function()
		vsc.action("bookmarks.listFromAllFiles")
	end, opts)
	map("n", "<Leader>B", function()
		vsc.action("editor.debug.action.toggleBreakpoint")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("]"), function()
		vsc.action("editor.action.indentLines")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("["), function()
		vsc.action("editor.action.outdentLines")
	end, opts)
	map({ "n", "x" }, "<C-M-l>", function()
		vsc.action("turboConsoleLog.displayLogMessage")
	end, opts)
	map({ "n", "x" }, "<Leader>un", function()
		vsc.action("notifications.hideToasts")
	end, opts)
	map("n", "<Leader>*",
		function()
			vsc.action("workbench.action.findInFiles",
				{
					args = { { query = vim.fn.expand("<cword>") } },
					count = 1
				})
		end, opts)

	map("x", "<Leader>*", function()
		local vsc = vsc
		vsc.action("workbench.action.findInFiles", {
			args = { { query = vsc.get_visual_selection() } },
			count = 1
		})
	end, opts)
	map("n", "<leader><space>", "<cmd>Find<cr>", opts)
	map("n", "<leader>/", function()
		vsc.action("workbench.action.findInFiles", { count = 1 })
	end, opts)
	map("n", "<leader>ss", function()
		vsc.action_marked("workbench.action.gotoSymbol", { count = 1 })
	end, opts)

	-- Folding
	map({ "n", "x" }, "za", function()
		vsc.action("editor.toggleFold")
	end, opts)
	map({ "n", "x" }, "zR", function()
		vsc.action("editor.unfoldAll")
	end, opts)
	map({ "n", "x" }, "zM", function()
		vsc.action("editor.foldAll")
	end, opts)
	map({ "n", "x" }, "zo", function()
		vsc.action("editor.unfold")
	end, opts)
	map({ "n", "x" }, "zO", function()
		vsc.action("editor.unfoldRecursively")
	end, opts)
	map({ "n", "x" }, "zc", function()
		vsc.action("editor.fold")
	end, opts)
	map({ "n", "x" }, "zC", function()
		vsc.action("editor.foldRecursively")
	end, opts)

	map({ "n", "x" }, "z1", function()
		vsc.action("editor.foldLevel1")
	end, opts)
	map({ "n", "x" }, "z2", function()
		vsc.action("editor.foldLevel2")
	end, opts)
	map({ "n", "x" }, "z3", function()
		vsc.action("editor.foldLevel3")
	end, opts)
	map({ "n", "x" }, "z4", function()
		vsc.action("editor.foldLevel4")
	end, opts)
	map({ "n", "x" }, "z5", function()
		vsc.action("editor.foldLevel5")
	end, opts)
	map({ "n", "x" }, "z6", function()
		vsc.action("editor.foldLevel6")
	end, opts)
	map({ "n", "x" }, "z7", function()
		vsc.action("editor.foldLevel7")
	end, opts)

	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("1"), function()
		vsc.action("editor.foldLevel1")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("2"), function()
		vsc.action("editor.foldLevel2")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("3"), function()
		vsc.action("editor.foldLevel3")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("4"), function()
		vsc.action("editor.foldLevel4")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("5"), function()
		vsc.action("editor.foldLevel5")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("6"), function()
		vsc.action("editor.foldLevel6")
	end, opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("7"), function()
		vsc.action("editor.foldLevel7")
	end, opts)

	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("["),
		function()
			vsc.action("editor.foldRecursively")
		end,
		opts
	)
	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("]"),
		function()
			vsc.action("editor.unfoldRecursively")
		end,
		opts
	)

	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("-"),
		function()
			vsc.action("editor.foldAllExcept")
		end,
		opts
	)
	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("="),
		function()
			vsc.action("editor.unfoldAllExcept")
		end,
		opts
	)

	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs(","),
		function()
			vsc.action("editor.createFoldingRangeFromSelection", {
				callback = function()
					local sel_start = vim.fn.getpos("v")
					local sel_end = vim.fn.getpos(".")
					if sel_end[2] > sel_start[2] then
						vim.api.nvim_feedkeys("o", "m", false)
					end
					local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
					vim.api.nvim_feedkeys(esc, "m", false)
				end,
				count = 1,
			})
		end,
		opts
	)
	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("."),
		function()
			vsc.call("editor.removeManualFoldingRanges")
			return "<esc>"
		end,
		expr_opts
	)

	map({ "n", "x" }, "zV", function()
		vsc.action("editor.foldAllExcept")
	end, opts)

	map("x", "zx", function()
		vsc.call("editor.createFoldingRangeFromSelection")
		return "<esc>"
	end, expr_opts)
	map({ "n", "x" }, "zX", function()
		vsc.action("editor.removeManualFoldingRanges")
	end, opts)

	map({ "n", "x" }, "]z", function()
		vsc.action("editor.gotoNextFold")
	end, opts)
	map({ "n", "x" }, "[z", function()
		vsc.action("editor.gotoPreviousFold")
	end, opts)

	-- Jumplist
	-- map("n", "<C-o>", "<C-o>", { remap = true, silent = true })
	-- map("n", "<C-i>", "<C-i>", { remap = true, silent = true })

	-- The <M-O> and <M-I> will be set by the mini.bracketed plugin
	-- map("n", "<M-O>", "<Cmd>call VSCodeNotify('workbench.action.openPreviousRecentlyUsedEditor')<CR>", opts)
	-- map("n", "<M-I>", "<Cmd>call VSCodeNotify('workbench.action.openNextRecentlyUsedEditor')<CR>", opts)

	map("v", "<C-o>", "<Cmd>call VSCodeNotify('workbench.action.navigateBack')<CR>", opts)
	map("v", "<C-i>", "<Cmd>call VSCodeNotify('workbench.action.navigateForward')<CR>", opts)

	map("n", "<Leader>`.", "`.", opts)
	map("n", "`.", "<Cmd>call VSCodeNotify('workbench.action.navigateToLastEditLocation')<CR>", opts)
	map("n", "<Leader>g;", "g;", opts)
	map("n", "<Leader>g,", "g,", opts)
	map("n", "g;", "<Cmd>call VSCodeNotify('workbench.action.navigateBackInEditLocations')<CR>", opts)
	map("n", "g,", "<Cmd>call VSCodeNotify('workbench.action.navigateForwardInEditLocations')<CR>", opts)

	map("n", "gd", function()
		vsc.go_to_definition_marked("revealDefinition")
	end, opts)
	map("n", "<Leader>gd", function()
		vsc.go_to_definition_marked("goToTypeDefinition")
	end, opts)
	map("n", "<F12>", function()
		vsc.go_to_definition_marked("revealDefinition")
	end, opts)
	map("n", "gf", function()
		vsc.go_to_definition_marked("revealDeclaration")
	end, opts)
	map("n", "<C-]>", function()
		vsc.go_to_definition_marked("revealDefinition")
	end, opts)
	map("n", "gO", function()
		vsc.action_marked("workbench.action.gotoSymbol", { count = 1 })
	end, opts)
	map("n", ctrl_cmd_lhs("O"), function()
		vsc.action_marked("workbench.action.gotoSymbol", { count = 1 })
	end, opts)
	map("n", "gF", function()
		vsc.action_marked("editor.action.peekDeclaration", { count = 1 })
	end, opts)
	map("n", "<S-F12>", function()
		vsc.action_marked("editor.action.goToReferences", { count = 1 })
	end, opts)
	map("n", "gH", function()
		vsc.action_marked("editor.action.referenceSearch.trigger", { count = 1 })
	end, opts)
	map("n", ctrl_cmd_lhs("S-F12"), function()
		vsc.action_marked("editor.action.peekImplementation", { count = 1 })
	end, opts)
	map("n", "<M-S-F12>", function()
		vsc.action_marked("references-view.findReferences", { count = 1 })
	end, opts)
	map("n", "gD", function()
		vsc.action_marked("editor.action.peekDefinition", { count = 1 })
	end, opts)
	map("n", "<M-F12>", function()
		vsc.action_marked("editor.action.peekDefinition", { count = 1 })
	end, opts)
	map("n", ctrl_cmd_lhs("F12"), function()
		vsc.action_marked("editor.action.goToImplementation", { count = 1 })
	end, opts)

	map("n", ctrl_cmd_lhs("."), "<Cmd>call VSCodeNotify('editor.action.quickFix')<CR>", opts)

	-- VSCode gx
	map("n", "gx", "<Cmd>call VSCodeNotify('editor.action.openLink')<CR>", opts)

	map("n", "<Leader>o", function()
		vsc.action("workbench.action.showOutputChannels", { count = 1 })
	end, opts)
	map("n", "<Leader>t", "<Cmd>call VSCodeNotify('workbench.action.tasks.runTask')<CR>", opts)
	map("n", "<Leader>uc", "<Cmd>call VSCodeNotify('workbench.action.toggleCenteredLayout')<CR>", opts)
	map("n", "<Leader>at", function()
		vsc.action("codeium.toggleEnable", {
			callback = function(err)
				if not err then
					vsc.action("notifications.toggleList")
				end
			end
		})
	end, opts)
	-- map("n", "<Leader>at", "<Cmd>call VSCodeNotify('aws.codeWhisperer.toggleCodeSuggestion')<CR>", opts)

	map("n", "<F2>", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
	map("n", "<Leader>r", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
	map("n", "<Leader>B", "<Cmd>call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>", opts)

	-- Undo/Redo
	map({ "n", "x" }, ctrl_cmd_lhs("z"), "<Cmd>call VSCodeNotify('undo')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("Z"), "<Cmd>call VSCodeNotify('redo')<CR>", opts)

	-- map("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", opts)
	-- map("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", opts)

	-- Add/Remove cursors

	---@param direction "above" | "below"
	local function vscode_action_insert_cursor(direction)
		local command = direction == "above" and "editor.action.insertCursorAbove" or "editor.action.insertCursorBelow"
		vim.api.nvim_feedkeys("i", "m", false)
		vsc.action(command)
	end

	local insert_cursor_below = function()
		vscode_action_insert_cursor("below")
	end

	local insert_cursor_above = function()
		vscode_action_insert_cursor("above")
	end

	map("n", ctrl_cmd_lhs("M-j"), insert_cursor_below, opts)
	map("n", ctrl_cmd_lhs("M-Down"), insert_cursor_below, opts)
	map("n", ctrl_cmd_lhs("M-k"), insert_cursor_above, opts)
	map("n", ctrl_cmd_lhs("M-Up"), insert_cursor_above, opts)
	map("x", ctrl_cmd_lhs("M-j"), function()
		vsc.action_insert_selection("editor.action.insertCursorBelow")
	end, opts)
	map("x", ctrl_cmd_lhs("M-Down"), function()
		vsc.action_insert_selection("editor.action.insertCursorBelow")
	end, opts)
	map("x", ctrl_cmd_lhs("M-k"), function()
		vsc.action_insert_selection("editor.action.insertCursorAbove")
	end, opts)
	map("x", ctrl_cmd_lhs("M-Up"), function()
		vsc.action_insert_selection("editor.action.insertCursorAbove")
	end, opts)

	-- Insert snippets
	map("n", ctrl_cmd_lhs("R"), function()
		vim.api.nvim_feedkeys("i", "m", false)
		vsc.action("editor.action.showSnippets", { count = 1 })
	end, opts)

	map("x", ctrl_cmd_lhs("R"), function()
		vsc.action_insert_selection("editor.action.showSnippets", { count = 1 })
	end, opts)

	-- Quick fixes and refactorings
	map("n", ctrl_cmd_lhs("."), "<Cmd>call VSCodeCall('editor.action.quickFix')<CR>", opts)
	map("x", ctrl_cmd_lhs("."), function()
		vsc.action_insert_selection("editor.action.quickFix", { count = 1 })
	end, opts)
	map("n", "<C-S-R>", function()
		vsc.action('editor.action.refactor', { count = 1 })
	end, opts)
	map("x", "<C-S-R>", function()
		vsc.action_insert_selection("editor.action.refactor", { count = 1 })
	end, opts)
	map("x", "<M-S>", function()
		vsc.action_insert_selection("editor.action.surroundWithSnippet", { count = 1 })
	end, opts)
	map("x", "<M-T>", function()
		vsc.action_insert_selection("surround.with", { count = 1 })
	end, opts)

	-- Formatting
	map({ "n", "x" }, "<M-F>", "<Cmd>call VSCodeCall('editor.action.formatDocument')<CR>", opts)
	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("f"),
		"<Cmd>call VSCodeCall('editor.action.formatSelection', 1)<CR>",
		opts
	)
end

-- Save
if vim.g.vscode then
	map({ "n", "x" }, ctrl_cmd_lhs("s"), "<Cmd>Write<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("S"), "<Cmd>Saveas<CR>", opts)
else
	map("n", "<Leader>W", function() vim.cmd "SudaWrite" end, { desc = "Save as sudo" })
end


-- Move lines down and up
if vim.g.vscode then
	map("n", "<M-Up>", function()
		vsc.move_line("Up")
	end, opts)
	map("n", "<M-Down>", function()
		vsc.move_line("Down")
	end, opts)
	map("n", "<M-k>", function()
		vsc.move_line("Up")
	end, opts)
	map("n", "<M-j>", function()
		vsc.move_line("Down")
	end, opts)
	map("x", "<M-Up>", function()
		vsc.move_visual_selection("Up")
	end, opts)
	map("x", "<M-Down>", function()
		vsc.move_visual_selection("Down")
	end, opts)
	map("x", "<M-k>", function()
		vsc.move_visual_selection("Up")
	end, opts)
	map("x", "<M-j>", function()
		vsc.move_visual_selection("Down")
	end, opts)
	map({ "n", "x" }, "<M-l>", function()
		vsc.action("editor.action.indentLines")
	end, opts)
	map({ "n", "x" }, "<M-h>", function()
		vsc.action("editor.action.outdentLines")
	end, opts)
	map({ "n", "x" }, "<M-D>", function()
		vsc.action("abracadabra.moveStatementDown")
	end, opts)
	map({ "n", "x" }, "<M-U>", function()
		vsc.action("abracadabra.moveStatementUp")
	end, opts)
else
	-- These keymaps will be overridden by keymaps from the mini.move plugin
	map("x", "<M-Up>", ":move '<-2<CR>gv=gv", opts)
	map("x", "<M-k>", ":move '<-2<CR>gv=gv", opts)
	map("x", "<M-Down>", ":move '>+1<CR>gv=gv", opts)
	map("x", "<M-j>", ":move '>+1<CR>gv=gv", opts)
	map("n", "<M-Up>", ":move .-2<CR>==", opts)
	map("n", "<M-k>", ":move .-2<CR>==", opts)
	map("n", "<M-Down>", ":move .+1<CR>==", opts)
	map("n", "<M-j>", ":move .+1<CR>==", opts)
end

-- Harpoon
-- if vim.g.vscode then
--   map("n", "<M-a>", function()
-- 		vsc.action("vscode-harpoon.addEditor")
-- 	end, opts)
--   map("n", "<M-p>", function()
-- 		vsc.action("vscode-harpoon.editorQuickPick")
-- 	end, opts)
--   map("n", "<M-s>", function()
-- 		vsc.action("vscode-harpoon.editEditors")
-- 	end, opts)
--   map("n", "<M-0>", function()
-- 		vsc.action("vscode-harpoon.editEditors")
-- 	end, opts)
--   map("n", "<M-1>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor1")
-- 	end, opts)
--   map("n", "<M-2>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor2")
-- 	end, opts)
--   map("n", "<M-3>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor3")
-- 	end, opts)
--   map("n", "<M-4>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor4")
-- 	end, opts)
--   map("n", "<M-5>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor5")
-- 	end, opts)
--   map("n", "<M-6>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor6")
-- 	end, opts)
--   map("n", "<M-7>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor7")
-- 	end, opts)
--   map("n", "<M-8>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor8")
-- 	end, opts)
--   map("n", "<M-9>", function()
-- 		vsc.action("vscode-harpoon.gotoEditor9")
-- 	end, opts)
-- end

-- Copy lines down and up
map("n", "<M-S-Up>", ":copy .<CR>k", opts)
map("x", "<M-S-Up>", '"ay`>"apgv', opts)
map("n", "<M-K>", ":copy .<CR>k", opts)
map("x", "<M-K>", '"ay`>"apgv', opts)
map("n", "<M-S-Down>", ":copy .<CR>", opts)
map("x", "<M-S-Down>", '"ay"aPgv', opts)
map("n", "<M-J>", ":copy .<CR>", opts)
map("x", "<M-J>", '"ay"aPgv', opts)
map("n", "<M-J>", ":copy .<CR>", opts)
map("x", "<M-J>", '"ay"aPgv', opts)

-- Delete word
map("n", "<C-Del>", "dw", opts)
map("i", "<C-Del>", "<space><esc>ce", opts)
map("n", "<C-S-Del>", "dW", opts)
map("i", "<C-S-Del>", "<Esc>lcW", opts)

-- change word with <C-c>
map("n", "<C-c>", "ciw")
