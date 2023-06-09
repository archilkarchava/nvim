vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 250 }
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  desc = "don't auto comment new line",
  pattern = "*",
  command = "setlocal formatoptions-=c formatoptions-=o",
})
