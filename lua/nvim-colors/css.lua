local bit = require("bit")

local M = {}

--- @param base10 integer
--- @return string
local function base10_to_rrggbb(base10)
  return "#" .. bit.tohex(base10, 6)
end

--- @return string, string
function M.get_fg_bg_from_colorscheme()
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

  return fg, bg
end

---@class ConvertCSSColorOptions
---@field color string
---@field fg_color string
---@field bg_color string
local ConvertCSSColorOptions = {}

---@class ConvertCSSColorResult
---@field contrast_with_fg number
---@field contrast_with_bg number
---@field highlight_bg string
---@field highlight_fg string
local ConvertCSSColorResult = {}

--- @param input ConvertCSSColorOptions
--- @return string
local function get_css_color_cache_key(input)
  return input.color .. ":" .. input.fg_color .. ":" .. input.bg_color
end

local CSS_COLOR_CACHE = {}

--- @param input ConvertCSSColorOptions
--- @return ConvertCSSColorResult?
function M.convert_css_color(input)
  local cache_key = get_css_color_cache_key(input)
  local hit = CSS_COLOR_CACHE[cache_key]
  if hit then
    return hit
  end

  local result = vim.fn.NvimColorsConvertCSSColorForHighlight(input)
  if result ~= vim.NIL then
    CSS_COLOR_CACHE[cache_key] = result
    return result
  end
end

--- @param result ConvertCSSColorResult
--- @return string
function M.get_nvim_hl_group_name(result)
  return string.format(
    "nvim_colors_%s_%s",
    string.gsub(result.highlight_fg, "#", ""),
    string.gsub(result.highlight_bg, "#", "")
  )
end

return M
