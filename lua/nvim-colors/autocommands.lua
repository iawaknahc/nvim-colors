local treesitter = require("nvim-colors.treesitter")

local autocmd_group_id = vim.api.nvim_create_augroup("nvim-colors", {})

local M = {}

function M.create_auto_commands()
  local autocmd_id = vim.api.nvim_create_autocmd(treesitter.EVENTS, {
    callback = treesitter.highlight,
    group = autocmd_group_id,
  })
end

return M
