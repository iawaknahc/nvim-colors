local treesitter = require("nvim-colors.treesitter")

local autocmd_group_id = vim.api.nvim_create_augroup("nvim-colors", {})

local M = {}

local function autocmd_callback(ev)
  local bufnr = ev.buf
  treesitter.highlight(bufnr)
end

function M.create_auto_commands()
  local autocmd_id = vim.api.nvim_create_autocmd(
    { "FileType", "BufWinEnter", "TextChanged", "InsertLeave" },
    {
      callback = autocmd_callback,
      group = autocmd_group_id,
    }
  )
end

return M
