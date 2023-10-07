vim.on_key(function(char)
  if vim.fn.mode() == "n" and not vim.b.leap_active then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then
      vim.cmd("nohlsearch")
    end
  end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

vim.api.nvim_set_hl(0, "YankColor", vim.g.vscode and { link = "FakeVisual" } or { link = "Visual" })

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

  local cancel_selection = function()
    require("vscode-neovim").call("cancelSelection")
  end

  vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    desc = "Get rid of leftover VS Code selection",
    pattern = "[vV\x16]:[^vV\x16]",
    callback = cancel_selection,
  })
end
