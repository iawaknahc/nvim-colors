local AUGROUP = vim.api.nvim_create_augroup("nvimcolors", { clear = true })
local NS = vim.api.nvim_create_namespace("nvimcolors")

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
    local enabled = vim.g.nvimcolors_enabled
    if enabled == nil then
      vim.b[ev.buf].nvimcolors_enabled = true
    elseif type(enabled) == "function" then
      vim.b[ev.buf].nvimcolors_enabled = enabled(ev)
    elseif type(enabled) == "boolean" then
      vim.b[ev.buf].nvimcolors_enabled = enabled
    else
      error(
        "vim.g.nvimcolors_enabled must be either nil, boolean, or a function taking autocmd event returning a boolean"
      )
    end
  end,
  group = AUGROUP,
})

vim.api.nvim_create_autocmd({ "BufUnload" }, {
  callback = function(ev)
    require("nvim-colors.impl_decoration_provider").autocmd(ev)
    vim.b[ev.buf].nvimcolors_enabled = nil
  end,
  group = AUGROUP,
})

vim.api.nvim_set_decoration_provider(NS, {
  on_start = function(_, displaytick)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_start(_, displaytick)
  end,
  on_buf = function(_, bufnr, displaytick)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_buf(_, bufnr, displaytick)
  end,
  on_win = function(_, winid, bufnr, toprow, botrow)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_win(_, winid, bufnr, toprow, botrow)
  end,
  -- on_range was introduced in Neovim 0.12
  -- Its primary user is the builtin treesitter highlight.
  -- It was an optimization over the deprecated on_line.
  -- See https://github.com/neovim/neovim/pull/31400
  on_range = function(_, winid, bufnr, begin_row, begin_col, end_row, end_col)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_range(
      _,
      winid,
      bufnr,
      begin_row,
      begin_col,
      end_row,
      end_col
    )
  end,
  on_end = function(_, displaytick)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_end(_, displaytick)
  end,
})
