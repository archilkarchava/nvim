vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 250 }
  end,
})

if vim.g.vscode then
  -- Fixes vim-matchup for scratch buffers in VS Code
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      if vim.bo.filetype == "" then
        vim.bo.filetype = "on"
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function()
      if vim.bo.filetype == "" then
        vim.cmd "filetype detect"
      end
    end
  })
end
