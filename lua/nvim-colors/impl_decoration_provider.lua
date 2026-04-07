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

function M.decoration_provider_on_win()
  vim.api.nvim_set_hl_ns_fast(NS)
end

---@param _ "range"
---@param _winid integer
---@param bufnr integer
---@param begin_row integer
---@param begin_col integer
---@param end_row integer
---@param end_col integer
function M.decoration_provider_on_range(_, _winid, bufnr, begin_row, begin_col, end_row, end_col)
  if vim.b[bufnr].nvimcolors_enabled == true then
    local fg, bg = get_fg_bg_from_colorscheme()

    for color_with_range in
      require("nvim-colors.treesitter").iter_colors(bufnr, {
        begin_row,
        begin_col,
        end_row,
        end_col,
      })
    do
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
end

return M
