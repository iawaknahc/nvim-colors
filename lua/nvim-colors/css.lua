local bit = require("bit")

local csscolor4 = require("nvim-colors.csscolor4")

local M = {}

--- @param base10 integer
--- @return string
local function base10_to_rrggbb(base10)
  return "#" .. bit.tohex(base10, 6)
end

--- @return color, color
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

  return csscolor4.hex(fg), csscolor4.hex(bg)
end

---@class (exact) ConvertCSSColorOptions
---@field color color
---@field fg_color color
---@field bg_color color
local ConvertCSSColorOptions = {}

---@class (exact) ConvertCSSColorResult
---@field highlight_bg string
---@field highlight_fg string
local ConvertCSSColorResult = {}

--- @param input ConvertCSSColorOptions
--- @return string
local function get_css_color_cache_key(input)
  return vim.json.encode(input)
end

---@type { [string]: ConvertCSSColorResult|nil }
local CSS_COLOR_CACHE = {}

--- @param input ConvertCSSColorOptions
--- @return ConvertCSSColorResult?
function M.convert_css_color(input)
  local cache_key = get_css_color_cache_key(input)
  local hit = CSS_COLOR_CACHE[cache_key]
  if hit then
    return hit
  end

  local c = csscolor4.alpha_blending_over(input.color, input.bg_color)

  local contrast_with_fg = math.abs(csscolor4.contrast_apca(c, input.fg_color))
  local contrast_with_bg = math.abs(csscolor4.contrast_apca(c, input.bg_color))

  local highlight_bg = csscolor4.css_gamut_map(c, "srgb")
  ---@type color
  local highlight_fg
  if contrast_with_fg < contrast_with_bg then
    highlight_fg = csscolor4.css_gamut_map(input.bg_color, "srgb")
  else
    highlight_fg = csscolor4.css_gamut_map(input.fg_color, "srgb")
  end

  ---@type ConvertCSSColorResult
  local result = {
    highlight_bg = csscolor4.to_hex(highlight_bg),
    highlight_fg = csscolor4.to_hex(highlight_fg),
  }

  CSS_COLOR_CACHE[cache_key] = result
  return result
end

return M
