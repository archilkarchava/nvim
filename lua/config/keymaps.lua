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
    return vim.fn.VSCodeNotify("cursorMove", { to = direction, by = "wrappedLine", value = vim.v.count1 })
  end
  map("v", "gk", function() move_wrapped("up") end, opts)
  map("v", "gj", function() move_wrapped("down") end, opts)
end

local move_wrapped_opts = { expr = true, silent = true, remap = true }
map({ "n" }, "k", "v:count == 0 ? 'gk' : 'k'", move_wrapped_opts)
map({ "n" }, "j", "v:count == 0 ? 'gj' : 'j'", move_wrapped_opts)

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

  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("c"),
    "<Cmd>call VSCodeNotifyVisual('editor.action.addCommentLine', 1)<CR>",
    opts)
  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("u"),
    "<Cmd>call VSCodeNotifyVisual('editor.action.removeCommentLine', 1)<CR>", opts)

  map({ "n", "x" }, "<M-A>", "<Cmd>call VSCodeNotifyVisual('editor.action.blockComment', 1)<CR>", opts)
end

if vim.g.vscode then
  map({ "n", "v" }, "<C-h>", "<Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>", opts)
  map({ "n", "v" }, "<C-k>", "<Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>", opts)
  map({ "n", "v" }, "<C-l>", "<Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>", opts)
  map({ "n", "v" }, "<C-j>", "<Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>", opts)
  map({ "n", "v" }, "<C-w><C-k>", "<Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>",
    opts)
else
  map({ "n", "v" }, "<C-h>", "<C-w>h", opts)
  map({ "n", "v" }, "<C-k>", "<C-w>k", opts)
  map({ "n", "v" }, "<C-l>", "<C-w>l", opts)
  map({ "n", "v" }, "<C-j>", "<C-w>j", opts)
end

if vim.g.vscode then
  -- VS Code search / replace
  map("n", ctrl_cmd_lhs("e"), "<Cmd>call VSCodeNotify('actions.findWithSelection')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("e"), "<Cmd>call VSCodeNotifyVisual('actions.findWithSelection', 1)<CR><Esc>",
    opts)
  map("n", ctrl_cmd_lhs("f"), "<Cmd>call VSCodeNotify('actions.find')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("f"), "<Cmd>call VSCodeNotifyVisual('actions.find', 1)<CR><Esc>",
    opts)
  map("n", ctrl_cmd_lhs("g"), "<Cmd>call VSCodeNotify('editor.action.nextMatchFindAction')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("g"), "<Cmd>call VSCodeNotifyVisual('editor.action.nextMatchFindAction', 1)<CR><Esc>",
    opts)
  map("n", ctrl_cmd_lhs("S-g"), "<Cmd>call VSCodeNotify('editor.action.previousMatchFindAction')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("S-g"),
    "<Cmd>call VSCodeNotifyVisual('editor.action.previousMatchFindAction', 1)<CR><Esc>",
    opts)
  map("n", ctrl_cmd_lhs("M-f"), "<Cmd>call VSCodeNotify('editor.action.startFindReplaceAction')<CR>i",
    opts)
  map("x", ctrl_cmd_lhs("M-f"),
    "<Cmd>call VSCodeNotifyVisual('editor.action.startFindReplaceAction', 1)<CR><Esc>i",
    opts)
  map("n", ctrl_cmd_lhs("S-."), "<Cmd>call VSCodeNotify('editor.action.inPlaceReplace.down')<CR>i",
    opts)
  map("x", ctrl_cmd_lhs("S-."),
    "<Cmd>call VSCodeNotifyVisual('editor.action.inPlaceReplace.down', 1)<CR><Esc>i",
    opts)
  map("n", ctrl_cmd_lhs("S-,"), "<Cmd>call VSCodeNotify('editor.action.inPlaceReplace.up')<CR>i",
    opts)
  map("x", ctrl_cmd_lhs("S-,"), "<Cmd>call VSCodeNotifyVisual('editor.action.inPlaceReplace.up', 1)<CR><Esc>i",
    opts)

  -- Insert line above / below
  map("n", ctrl_cmd_lhs("Enter"), 'o<Esc>0"_D',
    opts)
  map("n", ctrl_cmd_lhs("S-Enter"), 'O<Esc>0"_D',
    opts)
  map("x", ctrl_cmd_lhs("Enter"), '<Esc>o<Esc>0"_D',
    opts)
  map("x", ctrl_cmd_lhs("S-Enter"), '<Esc>O<Esc>0"_D',
    opts)

  -- Scroll
  map({ "n", "v" }, "<C-y>", "<Cmd>call VSCodeNotify('germanScroll.arminUp')<CR>",
    opts)
  map({ "n", "v" }, "<C-e>", "<Cmd>call VSCodeNotify('germanScroll.arminDown')<CR>",
    opts)
  map({ "n", "v" }, "<C-u>", "<Cmd>call VSCodeNotify('germanScroll.bertholdUp')<CR>",
    opts)
  map({ "n", "v" }, "<C-d>", "<Cmd>call VSCodeNotify('germanScroll.bertholdDown')<CR>",
    opts)
  map({ "n", "v" }, "<C-b>", "<Cmd>call VSCodeNotify('germanScroll.christaUp')<CR>",
    opts)
  map({ "n", "v" }, "<C-f>", "<Cmd>call VSCodeNotify('germanScroll.christaDown')<CR>",
    opts)

  map("n", ctrl_cmd_lhs("d"), "i<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("d"),
    "<Cmd>call VSCodeNotifyVisualEnd('editor.action.addSelectionToNextFindMatch', 1)<CR><Esc>i",
    opts)
  -- map("x", ctrl_cmd_lhs("d"),
  --   function()
  --     require("util.vsc").vscode_notify_visual("editor.action.addSelectionToNextFindMatch", 1)
  --     return "<Esc>i"
  --   end,
  --   expr_opts)
  map("x", "<Leader>v", "<Cmd>call VSCodeNotifyVisual('noop', 1)<CR>", opts)

  map("n", ctrl_cmd_lhs("l"), "0vj",
    opts)
  map("x", ctrl_cmd_lhs("l"), "<Cmd>call VSCodeNotify('expandLineSelection')<CR>",
    opts)
  map("n", ctrl_cmd_lhs("t"), "<Cmd>call VSCodeNotify('workbench.action.showAllSymbols')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("t"), "<Cmd>call VSCodeNotifyVisual('workbench.action.showAllSymbols', 1)<CR><Esc>",
    opts)
  map("n", ctrl_cmd_lhs("L"), "i<Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>",
    opts)
  map("x", ctrl_cmd_lhs("L"),
    "<Cmd>call VSCodeNotifyVisual('editor.action.selectHighlights', 1)<CR><Esc>i",
    opts)
  map("x", "<C-S-Left>", "<Esc>i<Cmd>call VSCodeNotifyVisual('editor.action.smartSelect.shrink', 1)<CR>",
    opts)
  map("n", "<C-S-Right>", "<Esc>i<Cmd>call VSCodeNotify('editor.action.smartSelect.expand')<CR>",
    opts)
  map("x", "<C-S-Right>", "<Esc>i<Cmd>call VSCodeNotifyVisual('editor.action.smartSelect.expand', 1)<CR>",
    opts)

  -- Revert file
  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("R"), "<Cmd>call VSCodeNotify('workbench.action.files.revert')<CR>",
    opts)

  -- Git revert
  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("r"),
    "<Cmd>call VSCodeNotifyVisual('git.revertSelectedRanges', 1)<CR>", opts)

  -- Git stage/unstage
  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("M-s"),
    "<Cmd>call VSCodeNotifyVisual('git.stageSelectedRanges', 1)<CR>", opts)
  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("n"),
    "<Cmd>call VSCodeNotifyVisual('git.unstageSelectedRanges', 1)<CR>", opts)

  -- Git changes
  map({ "n", "x" }, "]g",
    function()
      vim.fn.VSCodeNotify('workbench.action.editor.nextChange')
      vim.fn.VSCodeNotify('workbench.action.compareEditor.nextChange')
    end,
    opts)
  map({ "n", "x" }, "[g",
    function()
      vim.fn.VSCodeNotify('workbench.action.editor.previousChange')
      vim.fn.VSCodeNotify('workbench.action.compareEditor.previousChange')
    end,
    opts)

  map({ "n", "v" }, "<Leader>]g", "<Cmd>call VSCodeNotify('editor.action.dirtydiff.next')<CR>",
    opts)
  map({ "n", "v" }, "<Leader>[g", "<Cmd>call VSCodeNotify('editor.action.dirtydiff.previous')<CR>",
    opts)

  map("n", "<Leader>gC", "<Cmd>call VSCodeNotify('merge-conflict.accept.all-current')<CR>",
    opts)
  map("n", "<Leader>gI", "<Cmd>call VSCodeNotify('merge-conflict.accept.all-incoming')<CR>",
    opts)
  map("n", "<Leader>gB", "<Cmd>call VSCodeNotify('merge-conflict.accept.all-both')<CR>",
    opts)
  map("n", "<Leader>gc", "<Cmd>call VSCodeNotify('merge-conflict.accept.current')<CR>",
    opts)
  map("n", "<Leader>gi", "<Cmd>call VSCodeNotify('merge-conflict.accept.incoming')<CR>",
    opts)
  map("n", "<Leader>gb", "<Cmd>call VSCodeNotify('merge-conflict.accept.both')<CR>",
    opts)
  map("v", "<Leader>ga", "<Cmd>call VSCodeNotify('merge-conflict.accept.selection')<CR>",
    opts)
  map({ "n", "v" }, "]x", "<Cmd>call VSCodeNotify('merge-conflict.next')<CR>",
    opts)
  map({ "n", "v" }, "[x", "<Cmd>call VSCodeNotify('merge-conflict.previous')<CR>",
    opts)
  map({ "n", "v" }, "<Leader>]x", "<Cmd>call VSCodeNotify('merge.goToNextUnhandledConflict')<CR>",
    opts)
  map({ "n", "v" }, "<Leader>[x", "<Cmd>call VSCodeNotify('merge.goToPreviousUnhandledConflict')<CR>",
    opts)
  map({ "n", "v" }, "]d", "<Cmd>call VSCodeNotify('editor.action.marker.next')<CR>",
    opts)
  map({ "n", "v" }, "[d", "<Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>",
    opts)
  map("n", "<Leader>]d", "<Cmd>call VSCodeNotify('editor.action.marker.nextInFiles')<CR>",
    opts)
  map("n", "<Leader>[d", "<Cmd>call VSCodeNotify('editor.action.marker.prevInFiles')<CR>",
    opts)
  map({ "n", "v" }, "]b", function()
    vim.fn.VSCodeCall("editor.debug.action.goToNextBreakpoint")
    vim.fn.VSCodeNotify("workbench.action.focusActiveEditorGroup")
  end, opts)
  map({ "n", "v" }, "[b", function()
    vim.fn.VSCodeCall("editor.debug.action.goToPreviousBreakpoint")
    vim.fn.VSCodeNotify("workbench.action.focusActiveEditorGroup")
  end, opts)

  map("n", "<Leader>m", "<Cmd>call VSCodeNotify('bookmarks.toggle')<CR>",
    opts)
  map("n", "<Leader>M", "<Cmd>call VSCodeNotify('bookmarks.listFromAllFiles')<CR>",
    opts)
  map("n", "<Leader>B", "<Cmd>call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>",
    opts)
  map({ "n", "x" }, ctrl_cmd_lhs("]"), "<Cmd>call VSCodeNotifyVisual('editor.action.indentLines', 1)<CR>",
    opts)
  map({ "n", "x" }, ctrl_cmd_lhs("["), "<Cmd>call VSCodeNotifyVisual('editor.action.outdentLines', 1)<CR>",
    opts)
  map("x", ">", "<Cmd>call VSCodeNotifyVisual('editor.action.indentLines', 1)<CR>",
    opts)
  map("x", "<", "<Cmd>call VSCodeNotifyVisual('editor.action.outdentLines', 1)<CR>",
    opts)
  map("n", "<C-M-l>", "<Cmd>call VSCodeNotify('turboConsoleLog.displayLogMessage')<CR>",
    opts)
  map("x", "<C-M-l>", "<Cmd>call VSCodeNotifyVisual('turboConsoleLog.displayLogMessage', 1)<CR>",
    opts)
  map({ "n", "x" }, "<Leader>un", "<Cmd>call VSCodeNotify('notifications.hideToasts')<CR>", opts)
  map("n", "<Leader>*",
    "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>", opts)
  map("x", "<Leader>*",
    "<Cmd>call VSCodeNotifyVisual('workbench.action.findInFiles', 1)<CR><Esc>", opts)
  map("n", "<leader><space>", "<cmd>Find<cr>", opts)
  map("n", "<leader>/", "<Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>", opts)
  map("n", "<leader>ss", function() require("util.vsc").notify_marked("workbench.action.gotoSymbol") end, opts)

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

  map({ "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("["), "<Cmd>call VSCodeNotifyVisual('editor.foldRecursively', 1)<CR>",
    opts)
  map({ "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("]"), "<Cmd>call VSCodeNotifyVisual('editor.unfoldRecursively', 1)<CR>",
    opts)

  map({ "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("-"), "<Cmd>call VSCodeNotifyVisual('editor.foldAllExcept', 1)<CR>",
    opts)
  map({ "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("="), "<Cmd>call VSCodeNotifyVisual('editor.unfoldAllExcept', 1)<CR>",
    opts)

  map({ "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs(","),
    "<Cmd>call VSCodeNotifyVisual('editor.createFoldingRangeFromSelection', 1)<CR><Esc>", opts)
  map({ "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("."),
    "<Cmd>call VSCodeNotifyVisual('editor.removeManualFoldingRanges', 1)<CR><Esc>", opts)

  map({ "n", "x" }, "zV", "<Cmd>call VSCodeNotifyVisual('editor.foldAllExcept', 1)<CR>", opts)

  map("x", "zx", "<Cmd>call VSCodeNotify('editor.createFoldingRangeFromSelection')<CR><Esc>", opts)
  map({ "n", "x" }, "zX", "<Cmd>call VSCodeNotify('editor.removeManualFoldingRanges')<CR>", opts)

  map({ "n", "x" }, "zj", "<Cmd>call VSCodeNotify('editor.gotoNextFold')<CR>", opts)
  map({ "n", "x" }, "zk", "<Cmd>call VSCodeNotify('editor.gotoPreviousFold')<CR>", opts)

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

  map("n", "gd", function() require("util.vsc").go_to_definition_marked("revealDefinition") end,
    opts)
  map("n", "<F12>", function() require("util.vsc").go_to_definition_marked("revealDefinition") end,
    opts)
  map("n", "gf", function() require("util.vsc").go_to_definition_marked("revealDeclaration") end,
    opts)
  map("n", "<C-]>", function() require("util.vsc").go_to_definition_marked("revealDefinition") end,
    opts)
  map("n", "gO", function() require("util.vsc").notify_marked("workbench.action.gotoSymbol") end,
    opts)
  map("n", ctrl_cmd_lhs("O"),
    function() require("util.vsc").notify_marked("workbench.action.gotoSymbol") end, opts)
  map("n", "gF", function() require("util.vsc").notify_marked("editor.action.peekDeclaration") end,
    opts)
  map("n", "<S-F12>", function() require("util.vsc").notify_marked("editor.action.goToReferences") end,
    opts)
  map("n", "gH", function() require("util.vsc").notify_marked("editor.action.goToReferences") end,
    opts)
  map("n", ctrl_cmd_lhs("S-F12"),
    function() require("util.vsc").notify_marked("editor.action.peekImplementation") end,
    opts)
  map("n", "<M-S-F12>", function() require("util.vsc").notify_marked("references-view.findReferences") end,
    opts)
  map("n", "gD", function() require("util.vsc").notify_marked("editor.action.peekDefinition") end,
    opts)
  map("n", "<M-F12>", function() require("util.vsc").notify_marked("editor.action.peekDefinition") end,
    opts)
  map("n", ctrl_cmd_lhs("F12"),
    function() require("util.vsc").notify_marked("editor.action.goToImplementation") end,
    opts)

  map("n", ctrl_cmd_lhs("."), "<Cmd>call VSCodeNotify('editor.action.quickFix')<CR>",
    opts)


  -- VSCode gx
  map("n", "gx", "<Cmd>call VSCodeNotify('editor.action.openLink')<CR>", opts)

  -- Open output panel and switch to insert mode
  map("n", ctrl_cmd_lhs("U"), "i<Cmd>call VSCodeNotify('workbench.action.output.toggleOutput')<CR>", opts)
  map("x", ctrl_cmd_lhs("U"), "<Esc>i<Cmd>call VSCodeNotify('workbench.action.output.toggleOutput')<CR>", opts)

  map("n", "<Leader>l", "<Cmd>call VSCodeNotify('workbench.action.showOutputChannels')<CR>", opts)
  map("n", "<Leader>uc", "<Cmd>call VSCodeNotify('workbench.action.toggleCenteredLayout')<CR>", opts)
  -- map("n", "<Leader>at", function()
  --   local status_ok = pcall(vim.fn.VSCodeCall, "codeium.toggleEnable")
  --   if status_ok then
  --     vim.fn.VSCodeNotify('notifications.toggleList')
  --   end
  -- end, opts)
  map("n", "<Leader>at", "<Cmd>call VSCodeNotify('aws.codeWhisperer.toggleCodeSuggestion')<CR>", opts)

  map("n", "<F2>", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
  map("n", "<Leader>r", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
  map("n", "<Leader>B", "<Cmd>call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>", opts)

  -- Save
  map({ "n", "x" }, ctrl_cmd_lhs("s"), "<Cmd>Write<CR>", opts)
  map({ "n", "x" }, ctrl_cmd_lhs("S"), "<Cmd>Saveas<CR>", opts)


  -- Undo/Redo
  map({ "n", "x" }, ctrl_cmd_lhs("z"), "<Cmd>call VSCodeNotify('undo')<CR>", opts)
  map({ "n", "x" }, ctrl_cmd_lhs("Z"), "<Cmd>call VSCodeNotify('redo')<CR>", opts)

  -- map("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", opts)
  -- map("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", opts)

  -- Add/Remove cursors
  map("n", ctrl_cmd_lhs("M-Down"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorBelow')<CR>", opts)
  map("n", ctrl_cmd_lhs("M-Up"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorAbove')<CR>", opts)
  map("n", ctrl_cmd_lhs("M-j"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorBelow')<CR>", opts)
  map("n", ctrl_cmd_lhs("M-k"), "i<Cmd>call VSCodeNotify('editor.action.insertCursorAbove')<CR>", opts)

  -- Insert snippets
  map("n", ctrl_cmd_lhs("r"), "i<Cmd>call VSCodeNotify('editor.action.showSnippets')<CR>", opts)
  map("x", ctrl_cmd_lhs("r"), "<Cmd>call VSCodeNotifyVisual('editor.action.showSnippets', 1)<CR><Esc>i", opts)
  map("n", ctrl_cmd_lhs("R"), "i<Cmd>call VSCodeNotify('reactSnippets.search')<CR>", opts)
  map("x", ctrl_cmd_lhs("R"), "<Cmd>call VSCodeNotifyVisual('reactSnippets.search', 1)<CR><Esc>i", opts)

  -- Quick fixes and refactorings
  map("n", ctrl_cmd_lhs("."), "<Cmd>call VSCodeCall('editor.action.quickFix')<CR>", opts)
  map("x", ctrl_cmd_lhs("."), "<Cmd>call VSCodeCallVisual('editor.action.quickFix', 1)<CR><Esc>i", opts)
  map("n", "<C-S-R>", "<Cmd>call VSCodeCall('editor.action.refactor')<CR>", opts)
  map("x", "<C-S-R>", "<Cmd>call VSCodeCallVisual('editor.action.refactor', 1)<CR><Esc>i", opts)
  map("x", "<M-S>", "<Cmd>call VSCodeNotifyVisual('editor.action.surroundWithSnippet', 1)<CR><Esc>i", opts)
  map("x", ctrl_cmd_lhs("T"), "<Cmd>call VSCodeNotifyVisual('surround.with', 1)<CR><Esc>i", opts)

  -- Formatting
  map({ "n", "x" }, "<M-F>", "<Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>", opts)
  map({ "n", "x" }, ctrl_cmd_lhs("k") .. ctrl_cmd_lhs("f"),
    "<Cmd>call VSCodeNotifyVisual('editor.action.formatSelection', 1)<CR>", opts)
end

-- Move lines down and up
if vim.g.vscode then
  map("n", "<M-Up>", function() require("util.vsc").move_line("Up") end, opts)
  map("n", "<M-Down>", function() require("util.vsc").move_line("Down") end, opts)
  map("n", "<M-k>", function() require("util.vsc").move_line("Up") end, opts)
  map("n", "<M-j>", function() require("util.vsc").move_line("Down") end, opts)
  map("x", "<M-Up>", function() require("util.vsc").move_visual_selection("Up") end, opts)
  map("x", "<M-Down>", function() require("util.vsc").move_visual_selection("Down") end, opts)
  map("x", "<M-k>", function() require("util.vsc").move_visual_selection("Up") end, opts)
  map("x", "<M-j>", function() require("util.vsc").move_visual_selection("Down") end, opts)
  map({ "n", "x" }, "<M-l>", "<Cmd>call VSCodeNotifyVisual('editor.action.indentLines', 1)<CR>",
    opts)
  map({ "n", "x" }, "<M-h>", "<Cmd>call VSCodeNotifyVisual('editor.action.outdentLines', 1)<CR>",
    opts)
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

-- o and O indentation
-- map("n", "o", function()
--   if vim.v.count > 0 then
--     return "o"
--   end
--   return vim.fn.VSCodeNotify("editor.action.insertLineAfter")
-- end, { expr = true, silent = true })
-- map("n", "O", function()
--   if vim.v.count > 0 then
--     return "O"
--   end
--   return vim.fn.VSCodeNotify("editor.action.insertLineBefore")
-- end, { expr = true, silent = true })
