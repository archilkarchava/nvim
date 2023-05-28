local options = {
  showmode = true,
  undofile = false,
  undodir = vim.fn.stdpath("state") .. "/vscode_undo",
  smartindent = true,
  -- cindent = false,
  -- autoindent = false,
}

-- vim.cmd "filetype indent off"

for k, v in pairs(options) do
  vim.opt[k] = v
end
