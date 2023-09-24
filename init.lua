if table.unpack == nil then
	---@diagnostic disable-next-line: deprecated
	table.unpack = unpack
end

vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = "["

require("config.common_options")
if vim.g.vscode then
	require("config.vscode_options")
end

-- Lazy is a plugin manager
require("config.lazy")

require("config.autocommands")
require("config.keymaps")
