if table.unpack == nil then
	---@diagnostic disable-next-line: deprecated
	table.unpack = unpack
end

-- Visual highlight is cleared by the vscode-neovim extension
vim.api.nvim_set_hl(0, "FakeVisual", { bg = "#264f78" })
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
