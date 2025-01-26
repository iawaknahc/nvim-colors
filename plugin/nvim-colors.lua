if vim.g.loaded_nvim_colors then
  return
end

local treesitter = require("nvim-colors.treesitter")
local tailwindcss = require("nvim-colors.tailwindcss")

tailwindcss.setup()
treesitter.setup()

vim.api.nvim_create_user_command("NvimColorsBufEnable", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  treesitter.buf_enable(bufnr)
  tailwindcss.buf_enable(bufnr)
  vim.api.nvim__redraw({ buf = bufnr, valid = false })
end, {
  desc = "Enable nvim-colors in the current buffer.",
})

vim.api.nvim_create_user_command("NvimColorsBufDisable", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  treesitter.buf_disable(bufnr)
  tailwindcss.buf_disable(bufnr)
  vim.api.nvim__redraw({ buf = bufnr, valid = false })
end, {
  desc = "Disable nvim-colors in the current buffer.",
})

vim.g.loaded_nvim_colors = true
