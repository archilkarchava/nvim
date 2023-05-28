-- Math globals
vim.g.pi = 3.14159265359
vim.g.e = 2.71828182846

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- vim.g.secondary_locale = "ru"

local function escape(str)
	-- You need to escape these characters to work correctly
	local escape_chars = [[;,."|\]]
	return vim.fn.escape(str, escape_chars)
end

-- Recommended to use lua template string
local en = [[qwertyuiop[]asdfghjkl;zxcvbnm,.]]
local ru = [[йцукенгшщзхъфывапролджячсмитьбю]]
local en_shift = [[QWERTYUIOP{}ASDFGHJKL:ZXCVBNM<>]]
local ru_shift = [[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮ]]

local options = {
	-- langmap = vim.fn.join({
	-- 	-- | `to` should be first     | `from` should be second
	-- 	escape(ru_shift) .. ';' .. escape(en_shift),
	-- 	escape(ru) .. ';' .. escape(en),
	-- }, ','),
	backup = false,                         -- creates a backup file
	clipboard = "unnamedplus",              -- allows neovim to access the system clipboard
	cmdheight = 1,                          -- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 0,                       -- so that `` is visible in markdown files
	fileencoding = "utf-8",                 -- the encoding written to a file
	hlsearch = true,                        -- highlight all matches on previous search pattern
	ignorecase = true,                      -- ignore case in search patterns
	mouse = "a",                            -- allow the mouse to be used in neovim
	pumheight = 10,                         -- pop up menu height
	showmode = false,                       -- we don't need to see things like -- INSERT -- anymore
	showtabline = 0,                        -- always show tabs
	smartcase = true,                       -- smart case
	smartindent = true,                     -- make indenting smarter again
	splitbelow = true,                      -- force all horizontal splits to go below current window
	splitright = true,                      -- force all vertical splits to go to the right of current window
	swapfile = false,                       -- creates a swapfile
	termguicolors = true,                   -- set term gui colors (most terminals support this)
	timeout = true,
	timeoutlen = 1000,                      -- time to wait for a mapped sequence to complete (in milliseconds)
	undofile = true,                        -- enable persistent undo
	updatetime = 100,                       -- faster completion (4000ms default)
	writebackup = false,                    -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true,                       -- convert tabs to spaces
	shiftwidth = 2,                         -- the number of spaces inserted for each indentation
	tabstop = 2,                            -- insert 2 spaces for a tab
	cursorline = true,                      -- highlight the current line
	number = true,                          -- set numbered lines
	laststatus = 3,
	showcmd = false,
	ruler = false,
	relativenumber = true, -- set relative numbered lines
	numberwidth = 4,      -- set number column width to 2 {default 4}
	signcolumn = "yes",   -- always show the sign column, otherwise it would shift the text each time
	wrap = false,         -- display lines as one long line
	scrolloff = 6,        -- is one of my fav
	sidescrolloff = 6,
	guifont = { "JetBrains Mono NL", ":h15" },
	title = true,
	-- colorcolumn = '80',
	-- colorcolumn = "120",
}
-- vim.opt.fillchars.eob = " "
-- vim.opt.fillchars = vim.opt.fillchars + "vertleft: "
-- vim.opt.fillchars = vim.opt.fillchars + "vertright: "
vim.opt.fillchars = vim.opt.fillchars + "eob: "
vim.opt.fillchars:append({
	stl = " ",
})

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
