local NS = vim.api.nvim_create_namespace("nvimcolors")

local M = {}

--- @param base10 integer
--- @return string
local function base10_to_rrggbb(base10)
  local bit = require("bit")
  return "#" .. bit.tohex(base10, 6)
end

--- @param result nvimcolors.convert_css_color_for_highlight.result
--- @return string
local function get_nvim_hl_group_name(result)
  return string.format(
    "nvimcolors_hl_%s_%s",
    string.gsub(result.highlight_fg, "#", ""),
    string.gsub(result.highlight_bg, "#", "")
  )
end

--- @return nvimcolors.css.color, nvimcolors.css.color
local function get_fg_bg_from_colorscheme()
  local csscolor4 = require("nvim-colors.csscolor4")

  -- Our defaults.

  --- @type integer
  local fg_base10 = 16777215 -- this is 0xffffff in base10.
  --- @type integer
  local bg_base10 = 0 -- this is 0x000000 in base10.

  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  local normal_fg = normal.fg
  local normal_bg = normal.bg
  if normal_fg ~= nil then
    fg_base10 = normal_fg
  end
  if normal_bg ~= nil then
    bg_base10 = normal_bg
  end

  -- Convert base10 to #rrggbb
  local fg = base10_to_rrggbb(fg_base10)
  local bg = base10_to_rrggbb(bg_base10)

  return csscolor4.hex(fg), csscolor4.hex(bg)
end

---@class (exact) nvimcolors.convert_css_color_for_highlight.opts
---@field color nvimcolors.css.color
---@field fg_color nvimcolors.css.color
---@field bg_color nvimcolors.css.color

---@class (exact) nvimcolors.convert_css_color_for_highlight.result
---@field highlight_bg string
---@field highlight_fg string

---@type { [string]: nvimcolors.convert_css_color_for_highlight.result? }
local CSS_COLOR_CACHE = {}

--- @param input nvimcolors.convert_css_color_for_highlight.opts
--- @return string
local function get_css_color_cache_key(input)
  return vim.json.encode(input)
end

--- @param input nvimcolors.convert_css_color_for_highlight.opts
--- @return nvimcolors.convert_css_color_for_highlight.result?
local function convert_css_color_for_highlight(input)
  local cache_key = get_css_color_cache_key(input)
  local hit = CSS_COLOR_CACHE[cache_key]
  if hit then
    return hit
  end

  local csscolor4 = require("nvim-colors.csscolor4")

  local c = csscolor4.alpha_blending_over(input.color, input.bg_color)

  local contrast_with_fg = math.abs(csscolor4.contrast_apca(c, input.fg_color))
  local contrast_with_bg = math.abs(csscolor4.contrast_apca(c, input.bg_color))

  local highlight_bg = csscolor4.css_gamut_map(c, "srgb")
  ---@type nvimcolors.css.color
  local highlight_fg
  if contrast_with_fg < contrast_with_bg then
    highlight_fg = csscolor4.css_gamut_map(input.bg_color, "srgb")
  else
    highlight_fg = csscolor4.css_gamut_map(input.fg_color, "srgb")
  end

  ---@type nvimcolors.convert_css_color_for_highlight.result
  local result = {
    highlight_bg = csscolor4.to_hex(highlight_bg),
    highlight_fg = csscolor4.to_hex(highlight_fg),
  }

  CSS_COLOR_CACHE[cache_key] = result
  return result
end

--- @type table<integer, vim.treesitter.LanguageTree>
local ltree_by_bufnr = {}

---@param _ "start"
---@param _displaytick integer
---@return boolean?
function M.decoration_provider_on_start(_, _displaytick) end

---@param _ "end"
---@param _displaytick integer
function M.decoration_provider_on_end(_, _displaytick) end

---@param bufnr integer
---@return boolean?
function on_buf_impl(bufnr)
  -- The LSP implementation is enabled, this implementation should be no-op.
  if vim.lsp.is_enabled("nvim-colors") then
    return
  end

  -- The user has disabled for this buffer.
  if vim.b[bufnr].nvimcolors_enabled ~= true then
    return
  end

  if ltree_by_bufnr[bufnr] == nil then
    ltree_by_bufnr[bufnr] = require("nvim-colors.treesitter").vim_treesitter_get_parser(bufnr)
  end

  ---@type vim.treesitter.LanguageTree?
  local ltree = ltree_by_bufnr[bufnr]
  if ltree == nil then
    return
  end

  local range2s = {}
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(winid) == bufnr then
      -- This two lines were borrowed from https://github.com/neovim/neovim/blob/v0.12.0/runtime/lua/vim/treesitter/highlighter.lua#L565-L568
      local topline = vim.fn.line("w0", winid) - 1
      local botline = vim.fn.line("w$", winid) + 1
      local range2 = { topline, botline }
      table.insert(range2s, range2)
    end
  end

  if vim.b[bufnr].nvimcolors_parsing == true then
    return
  end

  vim.b[bufnr].nvimcolors_parsing = true
  local trees = ltree:parse(range2s, function(_, trees)
    -- The parsing finished more than 3ms.
    -- The next parse should be instant, so recursively trigger redraw.
    -- So next time, parse() should return non-nil.
    if trees ~= nil and vim.b[bufnr].nvimcolors_parsing == true then
      vim.b[bufnr].nvimcolors_parsing = nil
      vim.api.nvim__redraw({
        buf = bufnr,
        -- Discard pending updates.
        flush = false,
        -- Force full redraw.
        valid = true,
      })
    end
    if trees ~= nil then
    end
  end)
  if trees == nil then
    return
  end
end

---@param _ "buf"
---@param bufnr integer
---@param _displaytick integer
---@return boolean?
function M.decoration_provider_on_buf(_, bufnr, _displaytick)
  return on_buf_impl(bufnr)
end

---@param _ "win"
---@param winid integer
---@param bufnr integer
---@param toprow integer
---@param botrow integer
---@return boolean?
function M.decoration_provider_on_win(_, winid, bufnr, toprow, botrow)
  vim.api.nvim_set_hl_ns_fast(NS)
  return on_buf_impl(bufnr)
end

---@param _ "range"
---@param _winid integer
---@param bufnr integer
---@param begin_row integer
---@param begin_col integer
---@param end_row integer
---@param end_col integer
---@return boolean?
function M.decoration_provider_on_range(_, _winid, bufnr, begin_row, begin_col, end_row, end_col)
  -- The LSP implementation is enabled, this implementation should be no-op.
  if vim.lsp.is_enabled("nvim-colors") then
    return
  end

  -- The user has disabled for this buffer.
  if vim.b[bufnr].nvimcolors_enabled ~= true then
    return
  end

  ---@type vim.treesitter.LanguageTree?
  local ltree = ltree_by_bufnr[bufnr]
  if ltree == nil then
    return
  end

  local fg, bg = get_fg_bg_from_colorscheme()

  local iter = require("nvim-colors.treesitter").iter_colors(bufnr, ltree, {
    begin_row,
    begin_col,
    end_row,
    end_col,
  })
  for color_with_range in iter do
    local converted = convert_css_color_for_highlight({
      color = color_with_range.color,
      fg_color = fg,
      bg_color = bg,
    })
    if converted then
      local hl_group = get_nvim_hl_group_name(converted)
      -- Based on observation, we do not cache the calls to nvim_set_hl()
      -- It must be called in each draw cycle.
      vim.api.nvim_set_hl(NS, hl_group, {
        fg = converted.highlight_fg,
        bg = converted.highlight_bg,
      })
      vim.api.nvim_buf_set_extmark(bufnr, NS, color_with_range.range4[1], color_with_range.range4[2], {
        end_row = color_with_range.range4[3],
        end_col = color_with_range.range4[4],
        hl_group = hl_group,
        ephemeral = true,
      })
    end
  end
end

---@param ev vim.api.keyset.create_autocmd.callback_args
function M.autocmd(ev)
  if ev.event == "BufUnload" then
    ---@type vim.treesitter.LanguageTree?
    local ltree = ltree_by_bufnr[ev.buf]
    if ltree ~= nil then
      ltree:destroy()
    end
    ltree_by_bufnr[ev.buf] = nil
  end
end

return M
