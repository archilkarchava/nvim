if not vim.g.vscode then
	return {}
end

-- List plugins that will be enabled in VS Code here or add a "vscode = true" to the plugin spec
local enabled = {}

local Config = require("lazy.core.config")
local Plugin = require("lazy.core.plugin")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false

-- HACK: disable all plugins except the ones we want
local fix_disabled = Plugin.Spec.fix_disabled
function Plugin.Spec.fix_disabled(self)
	for _, plugin in pairs(self.plugins) do
		if not (vim.tbl_contains(enabled, plugin.name) or plugin.vscode) then
			plugin.enabled = false
		end
	end
	fix_disabled(self)
end

-- HACK: don't clean plugins in vscode
local update_state = Plugin.update_state
function Plugin.update_state()
	update_state()
	Config.to_clean = {}
end

return {
	{
		"archilkarchava/vscode.nvim",
		vscode = true,
		event = "VeryLazy",
		config = function()
			require("vscode-theme").setup({})
			require("vscode-theme").load()
		end,
	},
	{
		"archilkarchava/vim-EnhancedJumps",
		vscode = true,
		enabled = false,
		dependencies = {
			"inkarkat/vim-ingo-library",
		},
		keys = {
			{
				"<C-o>",
				"<Plug>EnhancedJumpsLocalOlder",
				mode = { "x", "n" },
				silent = true,
				desc =
				"Go to the previous jumplist location inside the current buffer"
			},
			{
				"<C-i>",
				"<Plug>EnhancedJumpsLocalNewer",
				mode = { "x", "n" },
				silent = true,
				desc =
				"Go to the next jumplist location inside the current buffer"
			},
		},
		init = function()
			vim.g.EnhancedJumps_no_mappings = true
		end,
	}
}
