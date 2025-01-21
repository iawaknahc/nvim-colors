if vim.g.loaded_nvim_colors then
  return
end

require("nvim-colors.treesitter").setup()

vim.g.loaded_nvim_colors = true
