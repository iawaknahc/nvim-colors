if vim.g.loaded_nvim_colors then
  return
end

require("nvim-colors.autocommands").create_auto_commands()

vim.g.loaded_nvim_colors = true
