vim.api.nvim_set_hl(0, "YankColor", vim.g.vscode and { bg = "#264f78" } or { link = "Visual" })

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank({ higroup = "YankColor", timeout = 250 })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  desc = 'don\'t auto comment new line inside regular "//" comments',
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.rs" },
  command = "setlocal comments-=:// comments+=fO://",
})

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  desc = 'don\'t auto comment new line inside regular "--" comments',
  pattern = { "*.lua" },
  command = "setlocal comments-=:-- comments+=fO:--",
})

-- vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
--   desc = "don't auto comment new line",
--   pattern = "*",
--   command = "setlocal formatoptions-=c formatoptions-=o",
-- })

if vim.g.vscode then
  vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Fixes vim-matchup for scratch buffers in VS Code",
    callback = function()
      vim.defer_fn(function()
        if vim.bo.filetype == "" or vim.bo.filetype == nil then
          vim.bo.filetype = ""
        end
      end, 50)
    end,
  })
end
