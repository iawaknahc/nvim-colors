local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

local CSS_COLOR_TO_CANONICAL_CACHE = {}
local CANONICAL_TO_CONVERSION_RESULT_CACHE = {}

local M = {}

local function get_query()
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, query = pcall(vim.treesitter.query.get, "colors", "colors")
  if not ok then
    return
  end
  if not query then
    return
  end

  return query
end

local function get_ltree(buf)
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, buf, "colors")
  if not ok then
    return
  end

  return ltree
end

local function get_highlight_group_normal()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  local result = {}
  if normal.fg ~= nil then
    result.fg_base10 = normal.fg
  end
  if normal.bg ~= nil then
    result.bg_base10 = normal.bg
  end
  return result
end

local function convert_css_color(css_color)
  local hit_canonical = CSS_COLOR_TO_CANONICAL_CACHE[css_color]
  if hit_canonical then
    local hit_result = CANONICAL_TO_CONVERSION_RESULT_CACHE[hit_canonical]
    if hit_result then
      return hit_result
    else
    end
  else
  end

  local input = get_highlight_group_normal()
  input.css_color = css_color
  local result = vim.fn.NvimColorsConvertCSSColorForHighlight(input)
  if result ~= vim.NIL then
    CSS_COLOR_TO_CANONICAL_CACHE[css_color] = result.canonical
    CANONICAL_TO_CONVERSION_RESULT_CACHE[result.canonical] = result
    return result
  end
end

local function convert_u32_argb_to_css(u32_argb)
  local argb = string.gsub(string.gsub(string.lower(u32_argb), "_", ""), "0x", "")
  local a = string.sub(argb, 1, 2)
  local rgb = string.sub(argb, 3, 9)
  return "#" .. rgb .. a
end

local function make_highlight_group(ns, result)
  local name = string.format("nvim_colors_%s", string.gsub(result.hex6, "#", ""))
  local opts = {
    bg = result.hex6,
  }
  if result.fg ~= nil then
    opts.fg = result.fg
  end
  vim.api.nvim_set_hl(ns, name, opts)
  return name
end

local function highlight_viewport(ns, viewport)
  local query = get_query()
  if not query then
    return
  end

  local range = viewport.win_visible_range

  local ltree = get_ltree(viewport.buf)
  if not ltree then
    return
  end

  local root = ltree:parse(range)[1]:root()

  for id, node, _metadata, _match in query:iter_captures(root, viewport.buf, range[1], range[2]) do
    local capture_name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    local text = vim.treesitter.get_node_text(node, viewport.buf)

    local result = nil
    if capture_name == "colors.css" then
      result = convert_css_color(text)
    elseif capture_name == "colors.u32_argb" then
      local css_color = convert_u32_argb_to_css(text)
      result = convert_css_color(css_color)
    end

    if result then
      local hl_group = make_highlight_group(ns, result)
      vim.api.nvim_buf_set_extmark(viewport.buf, ns, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        hl_group = hl_group,
        ephemeral = true,
      })
    end
  end
end

function M.setup()
  local ns = vim.api.nvim_create_namespace("nvim-colors")
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, winid, bufnr, toprow, botrow)
      -- toprow and botrow are 0indexing, end-inclusive.
      local viewport = {
        buf = bufnr,
        win = winid,
        win_visible_range = { toprow, botrow + 1 },
      }
      -- Enable our highlight namespace in the window.
      vim.api.nvim_win_set_hl_ns(winid, ns)
      highlight_viewport(ns, viewport)
    end,
  })
end

return M
