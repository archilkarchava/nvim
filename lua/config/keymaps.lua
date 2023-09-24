local Util = require("util")

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
		return require("vscode-neovim").notify("cursorMove", { to = direction, by = "wrappedLine", value = vim.v.count1 })
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

if not vim.g.vscode then
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
		"<Cmd>call VSCodeNotify('editor.action.addCommentLine')<CR>",
		opts
	)
	map(
		{ "n", "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("u"),
		"<Cmd>call VSCodeNotify('editor.action.removeCommentLine')<CR>",
		opts
	)

	map({ "n", "x" }, "<M-A>", "<Cmd>call VSCodeNotify('editor.action.blockComment')<CR>", opts)
end

if vim.g.vscode then
	map({ "n", "v" }, "<C-h>", "<Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>", opts)
	map({ "n", "v" }, "<C-k>", "<Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>", opts)
	map({ "n", "v" }, "<C-l>", "<Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>", opts)
	map({ "n", "v" }, "<C-j>", "<Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>", opts)
	map({ "n", "v" }, "<C-w><C-k>", "<Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>", opts)
else
	map({ "n", "v" }, "<C-h>", "<C-w>h", opts)
	map({ "n", "v" }, "<C-k>", "<C-w>k", opts)
	map({ "n", "v" }, "<C-l>", "<C-w>l", opts)
	map({ "n", "v" }, "<C-j>", "<C-w>j", opts)
end

if vim.g.vscode then
	-- Insert line above / below
	map("n", ctrl_cmd_lhs("Enter"), 'o<Esc>0"_D', opts)
	map("n", ctrl_cmd_lhs("S-Enter"), 'O<Esc>0"_D', opts)
	map("x", ctrl_cmd_lhs("Enter"), '<Esc>o<Esc>0"_D', opts)
	map("x", ctrl_cmd_lhs("S-Enter"), '<Esc>O<Esc>0"_D', opts)

	-- Copy text
	if Util.is_mac() then
		map("n", "<D-c>", "yy", opts)
		map("x", "<D-c>", "ygv<Esc>", opts)
	end

	map("n", ctrl_cmd_lhs("d"), "i<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>", opts)
	map("x", ctrl_cmd_lhs("d"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.addSelectionToNextFindMatch")
	end, opts)

	map("n", ctrl_cmd_lhs("l"), "0vj", opts)
	map("x", ctrl_cmd_lhs("l"), "<Cmd>call VSCodeNotify('expandLineSelection')<CR>", opts)
	map("n", ctrl_cmd_lhs("t"), "<Cmd>call VSCodeNotify('workbench.action.showAllSymbols')<CR>", opts)
	map("x", ctrl_cmd_lhs("t"), "<Cmd>call VSCodeNotify('workbench.action.showAllSymbols')<CR><Esc>", opts)
	map("n", ctrl_cmd_lhs("L"), "i<Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>", opts)
	map("x", ctrl_cmd_lhs("L"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.selectHighlights")
	end, opts)

	-- Revert file
	-- map(
	-- 	{ "n", "x" },
	-- 	ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("R"),
	-- 	"<Cmd>call VSCodeCall('workbench.action.files.revert')<CR>",
	-- 	opts
	-- )

	-- Git changes
	map({ "n", "x" }, "]g", function()
		require("vscode-neovim").notify("workbench.action.editor.nextChange")
		require("vscode-neovim").notify("workbench.action.compareEditor.nextChange")
	end, opts)
	map({ "n", "x" }, "[g", function()
		require("vscode-neovim").notify("workbench.action.editor.previousChange")
		require("vscode-neovim").notify("workbench.action.compareEditor.previousChange")
	end, opts)

	map({ "n", "v" }, "<Leader>]g", "<Cmd>call VSCodeNotify('editor.action.dirtydiff.next')<CR>", opts)
	map({ "n", "v" }, "<Leader>[g", "<Cmd>call VSCodeNotify('editor.action.dirtydiff.previous')<CR>", opts)

	map("n", "<Leader>gC", "<Cmd>call VSCodeNotify('merge-conflict.accept.all-current')<CR>", opts)
	map("n", "<Leader>gI", "<Cmd>call VSCodeNotify('merge-conflict.accept.all-incoming')<CR>", opts)
	map("n", "<Leader>gB", "<Cmd>call VSCodeNotify('merge-conflict.accept.all-both')<CR>", opts)
	map("n", "<Leader>gc", "<Cmd>call VSCodeNotify('merge-conflict.accept.current')<CR>", opts)
	map("n", "<Leader>gi", "<Cmd>call VSCodeNotify('merge-conflict.accept.incoming')<CR>", opts)
	map("n", "<Leader>gb", "<Cmd>call VSCodeNotify('merge-conflict.accept.both')<CR>", opts)
	map("v", "<Leader>ga", "<Cmd>call VSCodeNotify('merge-conflict.accept.selection')<CR>", opts)
	map({ "n", "v" }, "]x", "<Cmd>call VSCodeNotify('merge-conflict.next')<CR>", opts)
	map({ "n", "v" }, "[x", "<Cmd>call VSCodeNotify('merge-conflict.previous')<CR>", opts)
	map({ "n", "v" }, "<Leader>]x", "<Cmd>call VSCodeNotify('merge.goToNextUnhandledConflict')<CR>", opts)
	map({ "n", "v" }, "<Leader>[x", "<Cmd>call VSCodeNotify('merge.goToPreviousUnhandledConflict')<CR>", opts)
	map({ "n", "v" }, "]d", "<Cmd>call VSCodeNotify('editor.action.marker.next')<CR>", opts)
	map({ "n", "v" }, "[d", "<Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>", opts)
	map("n", "<Leader>]d", "<Cmd>call VSCodeNotify('editor.action.marker.nextInFiles')<CR>", opts)
	map("n", "<Leader>[d", "<Cmd>call VSCodeNotify('editor.action.marker.prevInFiles')<CR>", opts)
	map({ "n", "v" }, "]b", function()
		vim.fn.VSCodeCall("editor.debug.action.goToNextBreakpoint")
		require("vscode-neovim").notify("workbench.action.focusActiveEditorGroup")
	end, opts)
	map({ "n", "v" }, "[b", function()
		vim.fn.VSCodeCall("editor.debug.action.goToPreviousBreakpoint")
		require("vscode-neovim").notify("workbench.action.focusActiveEditorGroup")
	end, opts)

	map("n", "<Leader>m", "<Cmd>call VSCodeNotify('bookmarks.toggle')<CR>", opts)
	map("n", "<Leader>M", "<Cmd>call VSCodeNotify('bookmarks.listFromAllFiles')<CR>", opts)
	map("n", "<Leader>B", "<Cmd>call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("]"), "<Cmd>call VSCodeNotify('editor.action.indentLines')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("["), "<Cmd>call VSCodeNotify('editor.action.outdentLines')<CR>", opts)
	map("x", ">", "<Cmd>call VSCodeNotify('editor.action.indentLines')<CR>", opts)
	map("x", "<", "<Cmd>call VSCodeNotify('editor.action.outdentLines')<CR>", opts)
	map({ "n", "x" }, "<C-M-l>", "<Cmd>call VSCodeNotify('turboConsoleLog.displayLogMessage')<CR>", opts)
	map({ "n", "x" }, "<Leader>un", "<Cmd>call VSCodeNotify('notifications.hideToasts')<CR>", opts)
	map(
		"n",
		"<Leader>*",
		"<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>",
		opts
	)
	map("x", "<Leader>*", "<Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR><Esc>", opts)
	map("n", "<leader><space>", "<cmd>Find<cr>", opts)
	map("n", "<leader>/", "<Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>", opts)
	map("n", "<leader>ss", function()
		require("util.vsc").notify_marked("workbench.action.gotoSymbol")
	end, opts)

	-- Folding
	map({ "n", "x" }, "za", "<Cmd>call VSCodeNotify('editor.toggleFold')<CR>", opts)
	map({ "n", "x" }, "zR", "<Cmd>call VSCodeNotify('editor.unfoldAll')<CR>", opts)
	map({ "n", "x" }, "zM", "<Cmd>call VSCodeNotify('editor.foldAll')<CR>", opts)
	map({ "n", "x" }, "zo", "<Cmd>call VSCodeNotify('editor.unfold')<CR>", opts)
	map({ "n", "x" }, "zO", "<Cmd>call VSCodeNotify('editor.unfoldRecursively')<CR>", opts)
	map({ "n", "x" }, "zc", "<Cmd>call VSCodeNotify('editor.fold')<CR>", opts)
	map({ "n", "x" }, "zC", "<Cmd>call VSCodeNotify('editor.foldRecursively')<CR>", opts)

	map({ "n", "x" }, "z1", "<Cmd>call VSCodeNotify('editor.foldLevel1')<CR>", opts)
	map({ "n", "x" }, "z2", "<Cmd>call VSCodeNotify('editor.foldLevel2')<CR>", opts)
	map({ "n", "x" }, "z3", "<Cmd>call VSCodeNotify('editor.foldLevel3')<CR>", opts)
	map({ "n", "x" }, "z4", "<Cmd>call VSCodeNotify('editor.foldLevel4')<CR>", opts)
	map({ "n", "x" }, "z5", "<Cmd>call VSCodeNotify('editor.foldLevel5')<CR>", opts)
	map({ "n", "x" }, "z6", "<Cmd>call VSCodeNotify('editor.foldLevel6')<CR>", opts)
	map({ "n", "x" }, "z7", "<Cmd>call VSCodeNotify('editor.foldLevel7')<CR>", opts)

	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("1"), "<Cmd>call VSCodeNotify('editor.foldLevel1')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("2"), "<Cmd>call VSCodeNotify('editor.foldLevel2')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("3"), "<Cmd>call VSCodeNotify('editor.foldLevel3')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("4"), "<Cmd>call VSCodeNotify('editor.foldLevel4')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("5"), "<Cmd>call VSCodeNotify('editor.foldLevel5')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("6"), "<Cmd>call VSCodeNotify('editor.foldLevel6')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("7"), "<Cmd>call VSCodeNotify('editor.foldLevel7')<CR>", opts)

	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("["),
		"<Cmd>call VSCodeNotify('editor.foldRecursively')<CR>",
		opts
	)
	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("]"),
		"<Cmd>call VSCodeNotify('editor.unfoldRecursively')<CR>",
		opts
	)

	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("-"),
		"<Cmd>call VSCodeNotify('editor.foldAllExcept')<CR>",
		opts
	)
	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("="),
		"<Cmd>call VSCodeNotify('editor.unfoldAllExcept')<CR>",
		opts
	)

	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs(","),
		"<Cmd>call VSCodeNotify('editor.createFoldingRangeFromSelection')<CR><Esc>",
		opts
	)
	map(
		{ "x" },
		ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("."),
		"<Cmd>call VSCodeNotify('editor.removeManualFoldingRanges')<CR><Esc>",
		opts
	)

	map({ "n", "x" }, "zV", "<Cmd>call VSCodeNotify('editor.foldAllExcept')<CR>", opts)

	map("x", "zx", "<Cmd>call VSCodeNotify('editor.createFoldingRangeFromSelection')<CR><Esc>", opts)
	map({ "n", "x" }, "zX", "<Cmd>call VSCodeNotify('editor.removeManualFoldingRanges')<CR>", opts)

	map({ "n", "x" }, "]z", "<Cmd>call VSCodeNotify('editor.gotoNextFold')<CR>", opts)
	map({ "n", "x" }, "[z", "<Cmd>call VSCodeNotify('editor.gotoPreviousFold')<CR>", opts)

	-- Jumplist
	-- map("n", "<C-o>", "<C-o>", { remap = true, silent = true })
	-- map("n", "<C-i>", "<C-i>", { remap = true, silent = true })

	-- The <M-O> and <M-I> will be set by the mini.bracketed plugin
	-- map("n", "<M-O>", "<Cmd>call VSCodeNotify('workbench.action.openPreviousRecentlyUsedEditor')<CR>", opts)
	-- map("n", "<M-I>", "<Cmd>call VSCodeNotify('workbench.action.openNextRecentlyUsedEditor')<CR>", opts)

	-- map("n", "<M-O>", "[j", { remap = true })
	-- map("n", "<M-I>", "]j", { remap = true })

	map("v", "<C-o>", "<Cmd>call VSCodeNotify('workbench.action.navigateBack')<CR>", opts)
	map("v", "<C-i>", "<Cmd>call VSCodeNotify('workbench.action.navigateForward')<CR>", opts)

	map("n", "<Leader>`.", "`.", opts)
	map("n", "`.", "<Cmd>call VSCodeNotify('workbench.action.navigateToLastEditLocation')<CR>", opts)
	map("n", "<Leader>g;", "g;", opts)
	map("n", "<Leader>g,", "g,", opts)
	map("n", "g;", "<Cmd>call VSCodeNotify('workbench.action.navigateBackInEditLocations')<CR>", opts)
	map("n", "g,", "<Cmd>call VSCodeNotify('workbench.action.navigateForwardInEditLocations')<CR>", opts)

	map("n", "gd", function()
		require("util.vsc").go_to_definition_marked("revealDefinition")
	end, opts)
	map("n", "<F12>", function()
		require("util.vsc").go_to_definition_marked("revealDefinition")
	end, opts)
	map("n", "gf", function()
		require("util.vsc").go_to_definition_marked("revealDeclaration")
	end, opts)
	map("n", "<C-]>", function()
		require("util.vsc").go_to_definition_marked("revealDefinition")
	end, opts)
	map("n", "gO", function()
		require("util.vsc").notify_marked("workbench.action.gotoSymbol")
	end, opts)
	map("n", ctrl_cmd_lhs("O"), function()
		require("util.vsc").notify_marked("workbench.action.gotoSymbol")
	end, opts)
	map("n", "gF", function()
		require("util.vsc").notify_marked("editor.action.peekDeclaration")
	end, opts)
	map("n", "<S-F12>", function()
		require("util.vsc").notify_marked("editor.action.goToReferences")
	end, opts)
	map("n", "gH", function()
		require("util.vsc").notify_marked("editor.action.goToReferences")
	end, opts)
	map("n", ctrl_cmd_lhs("S-F12"), function()
		require("util.vsc").notify_marked("editor.action.peekImplementation")
	end, opts)
	map("n", "<M-S-F12>", function()
		require("util.vsc").notify_marked("references-view.findReferences")
	end, opts)
	map("n", "gD", function()
		require("util.vsc").notify_marked("editor.action.peekDefinition")
	end, opts)
	map("n", "<M-F12>", function()
		require("util.vsc").notify_marked("editor.action.peekDefinition")
	end, opts)
	map("n", ctrl_cmd_lhs("F12"), function()
		require("util.vsc").notify_marked("editor.action.goToImplementation")
	end, opts)

	map("n", ctrl_cmd_lhs("."), "<Cmd>call VSCodeNotify('editor.action.quickFix')<CR>", opts)

	-- VSCode gx
	map("n", "gx", "<Cmd>call VSCodeNotify('editor.action.openLink')<CR>", opts)

	map("n", "<Leader>l", "<Cmd>call VSCodeNotify('workbench.action.showOutputChannels')<CR>", opts)
	map("n", "<Leader>uc", "<Cmd>call VSCodeNotify('workbench.action.toggleCenteredLayout')<CR>", opts)
	map("n", "<Leader>at", function()
		local status_ok = pcall(require("vscode-neovim").call, "codeium.toggleEnable")
		if status_ok then
			require("vscode-neovim").notify("notifications.toggleList")
		end
	end, opts)
	-- map("n", "<Leader>at", "<Cmd>call VSCodeNotify('aws.codeWhisperer.toggleCodeSuggestion')<CR>", opts)

	map("n", "<F2>", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
	map("n", "<Leader>r", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
	map("n", "<Leader>B", "<Cmd>call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>", opts)

	-- Undo/Redo
	map({ "n", "x" }, ctrl_cmd_lhs("z"), "<Cmd>call VSCodeCall('undo')<CR>", opts)
	map({ "n", "x" }, ctrl_cmd_lhs("Z"), "<Cmd>call VSCodeCall('redo')<CR>", opts)

	-- map("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", opts)
	-- map("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", opts)

	-- Add/Remove cursors
	map("n", ctrl_cmd_lhs("M-Down"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorBelow')<CR>", opts)
	map("n", ctrl_cmd_lhs("M-Up"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorAbove')<CR>", opts)
	map("n", ctrl_cmd_lhs("M-j"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorBelow')<CR>", opts)
	map("n", ctrl_cmd_lhs("M-k"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorAbove')<CR>", opts)
	map("x", ctrl_cmd_lhs("M-Down"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.insertCursorBelow")
	end, opts)
	map("x", ctrl_cmd_lhs("M-Up"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.insertCursorAbove")
	end, opts)
	map("x", ctrl_cmd_lhs("M-j"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.insertCursorBelow")
	end, opts)
	map("x", ctrl_cmd_lhs("M-k"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.insertCursorAbove")
	end, opts)

	-- Insert snippets
	map("n", ctrl_cmd_lhs("r"), "i<Cmd>call VSCodeNotify('editor.action.showSnippets')<CR>", opts)
	map("x", ctrl_cmd_lhs("r"), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.showSnippets")
	end, opts)
	map("n", ctrl_cmd_lhs("R"), "i<Cmd>call VSCodeNotify('reactSnippets.search')<CR>", opts)
	map("x", ctrl_cmd_lhs("R"), function()
		require("util.vsc").vscode_notify_insert_selection("reactSnippets.search")
	end, opts)

	-- Quick fixes and refactorings
	map("n", ctrl_cmd_lhs("."), "<Cmd>call VSCodeCall('editor.action.quickFix')<CR>", opts)
	map("x", ctrl_cmd_lhs("."), function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.quickFix")
	end, opts)
	map("n", "<C-S-R>", function()
		require("vscode-neovim").notify('editor.action.refactor')
	end, opts)
	map("x", "<C-S-R>", function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.refactor")
	end, opts)
	map("x", "<M-S>", function()
		require("util.vsc").vscode_notify_insert_selection("editor.action.surroundWithSnippet")
	end, opts)
	map("x", "<M-T>", function()
		require("util.vsc").vscode_notify_insert_selection("surround.with")
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
	map("n", "<Leader>w", "<Cmd>w<CR>", { desc = "Save" })
	map("n", "<Leader>W", function() vim.cmd "SudaWrite" end, { desc = "Save as sudo" })
end


-- Move lines down and up
if vim.g.vscode then
	map("n", "<M-Up>", function()
		require("util.vsc").move_line("Up")
	end, opts)
	map("n", "<M-Down>", function()
		require("util.vsc").move_line("Down")
	end, opts)
	map("n", "<M-k>", function()
		require("util.vsc").move_line("Up")
	end, opts)
	map("n", "<M-j>", function()
		require("util.vsc").move_line("Down")
	end, opts)
	map("x", "<M-Up>", function()
		require("util.vsc").move_visual_selection("Up")
	end, opts)
	map("x", "<M-Down>", function()
		require("util.vsc").move_visual_selection("Down")
	end, opts)
	map("x", "<M-k>", function()
		require("util.vsc").move_visual_selection("Up")
	end, opts)
	map("x", "<M-j>", function()
		require("util.vsc").move_visual_selection("Down")
	end, opts)
	map({ "n", "x" }, "<M-l>", "<Cmd>call VSCodeNotify('editor.action.indentLines')<CR>", opts)
	map({ "n", "x" }, "<M-h>", "<Cmd>call VSCodeNotify('editor.action.outdentLines')<CR>", opts)
	map({ "n", "x" }, "<M-D>", "<Cmd>call VSCodeNotify('abracadabra.moveStatementDown')<CR>", opts)
	map({ "n", "x" }, "<M-U>", "<Cmd>call VSCodeNotify('abracadabra.moveStatementUp')<CR>", opts)
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
--   map("n", "<M-a>", "<Cmd>call VSCodeNotify('vscode-harpoon.addEditor')<CR>", opts)
--   map("n", "<M-p>", "<Cmd>call VSCodeNotify('vscode-harpoon.editorQuickPick')<CR>", opts)
--   map("n", "<M-s>", "<Cmd>call VSCodeNotify('vscode-harpoon.editEditors')<CR>", opts)
--   map("n", "<M-0>", "<Cmd>call VSCodeNotify('vscode-harpoon.editEditors')<CR>", opts)
--   map("n", "<M-1>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor1')<CR>", opts)
--   map("n", "<M-2>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor2')<CR>", opts)
--   map("n", "<M-3>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor3')<CR>", opts)
--   map("n", "<M-4>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor4')<CR>", opts)
--   map("n", "<M-5>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor5')<CR>", opts)
--   map("n", "<M-6>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor6')<CR>", opts)
--   map("n", "<M-7>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor7')<CR>", opts)
--   map("n", "<M-8>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor8')<CR>", opts)
--   map("n", "<M-9>", "<Cmd>call VSCodeNotify('vscode-harpoon.gotoEditor9')<CR>", opts)
-- end

map({ "n", "x" }, "<M-o>", "``", opts)

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

-- o and O indentation
-- map("n", "o", function()
--   if vim.v.count > 0 then
--     return "o"
--   end
--   return require("vscode-neovim").notify("editor.action.insertLineAfter")
-- end, { expr = true, silent = true })
-- map("n", "O", function()
--   if vim.v.count > 0 then
--     return "O"
--   end
--   return require("vscode-neovim").notify("editor.action.insertLineBefore")
-- end, { expr = true, silent = true })
