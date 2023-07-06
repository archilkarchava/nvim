if not vim.g.vscode then
	return {}
end

-- List plugins that will be enabled in VS Code here or add a "vscode = true" to the plugin spec
local enabled = {}

local Config = require("lazy.core.config")
local Plugin = require("lazy.core.plugin")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
	return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

return {
	{
		"archilkarchava/vscode.nvim",
		vscode = true,
		lazy = false,
		priority = 1000,
		config = function()
			require("vscode-theme").setup({})
			require("vscode-theme").load()
		end,
	},
}
