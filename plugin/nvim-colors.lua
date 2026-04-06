if vim.g.loaded_nvim_colors then
  return
end

local augroup = vim.api.nvim_create_augroup("nvim-colors/treesitter", {})
local ns = vim.api.nvim_create_namespace("nvim-colors/treesitter")

vim.api.nvim_create_autocmd({
  -- For cases
  -- 1. vim.api.nvim_create_buf, used by plugins like fzf-lua and blink.cmp.
  -- 2. :h buffer-reuse. It is observed that when reuse happens, BufNew is fired.
  "BufNew",

  -- For cases
  -- 1. nvim some-not-existing-file
  "BufNewFile",

  -- For cases
  -- 1. nvim some-existing-file
  "BufReadPost",
}, {
  callback = function(ev)
    require("nvim-colors.treesitter").autocmd_callback_attach(ev)
  end,
  group = augroup,
})

vim.api.nvim_create_autocmd({ "BufUnload" }, {
  callback = function(ev)
    require("nvim-colors.treesitter").autocmd_callback_detach(ev)
  end,
  group = augroup,
})

vim.api.nvim_set_decoration_provider(ns, {
  on_win = function()
    require("nvim-colors.treesitter").decoration_provider_on_win()
  end,
  -- on_range was introduced in Neovim 0.12
  -- Its primary user is the builtin treesitter highlight.
  -- It was an optimization over the deprecated on_line.
  -- See https://github.com/neovim/neovim/pull/31400
  on_range = function(_, winid, bufnr, begin_row, begin_col, end_row, end_col)
    require("nvim-colors.treesitter").decoration_provider_on_range(
      _,
      winid,
      bufnr,
      begin_row,
      begin_col,
      end_row,
      end_col
    )
  end,
})

vim.api.nvim_create_user_command("NvimColorsBufEnable", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  require("nvim-colors.treesitter").buf_enable(bufnr)
end, {
  desc = "Enable nvim-colors in the current buffer.",
})

vim.api.nvim_create_user_command("NvimColorsBufDisable", function(_)
  local bufnr = vim.api.nvim_get_current_buf()
  require("nvim-colors.treesitter").buf_disable(bufnr)
end, {
  desc = "Disable nvim-colors in the current buffer.",
})

vim.g.loaded_nvim_colors = true
