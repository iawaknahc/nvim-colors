if vim.g.loaded_nvim_colors then
  return
end

local treesitter = require("nvim-colors.treesitter")

local augroup = vim.api.nvim_create_augroup("nvim-colors", {})

treesitter.setup({ augroup = augroup })

vim.api.nvim_create_user_command("NvimColorsBufEnable", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  treesitter.buf_enable(bufnr)
  vim.api.nvim__redraw({ buf = bufnr, valid = false })
end, {
  desc = "Enable nvim-colors in the current buffer.",
})

vim.api.nvim_create_user_command("NvimColorsBufDisable", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  treesitter.buf_disable(bufnr)
  vim.api.nvim__redraw({ buf = bufnr, valid = false })
end, {
  desc = "Disable nvim-colors in the current buffer.",
})

vim.g.loaded_nvim_colors = true
