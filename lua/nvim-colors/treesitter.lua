local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

local plugin_ns = vim.api.nvim_create_namespace("nvim-colors")
vim.api.nvim_set_hl_ns(plugin_ns)

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
    logger:debug("cache hit: %s -> %s", css_color, hit_canonical)
    local hit_result = CANONICAL_TO_CONVERSION_RESULT_CACHE[hit_canonical]
    if hit_result then
      logger:debug("cache hit: %s -> %s", hit_canonical, hit_result.hex6)
      return hit_result
    else
      logger:debug("cache miss: %s", hit_canonical)
    end
  else
    logger:debug("cache miss: %s", css_color)
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

local function make_highlight_group(result)
  local name = string.format("nvim_colors_%s", string.gsub(result.hex6, "#", ""))
  local opts = {
    bg = result.hex6,
  }
  if result.fg ~= nil then
    opts.fg = result.fg
  end
  vim.api.nvim_set_hl(plugin_ns, name, opts)
  return name
end

local function get_viewport(buf)
  local tabpages = vim.api.nvim_list_tabpages()
  for _, tabpage in ipairs(tabpages) do
    local windows = vim.api.nvim_tabpage_list_wins(tabpage)
    for _, win in pairs(windows) do
      local that_buf = vim.api.nvim_win_get_buf(win)
      if that_buf == buf then
        local win_height = vim.api.nvim_win_get_height(win)
        local cursor_10indexing = vim.api.nvim_win_get_cursor(win)
        local buf_line_count = vim.api.nvim_buf_line_count(buf)
        return {
          tabpage = tabpage,
          win = win,
          win_height = win_height,
          cursor_10indexing = cursor_10indexing,
          buf = buf,
          buf_line_count = buf_line_count,
        }
      end
    end
  end
end

local function estimiate_highlight_range(viewport)
  local cursor_line_00indexing = math.max(0, viewport.cursor_10indexing[1] - 1)

  local top = math.max(0, cursor_line_00indexing - viewport.win_height)

  local bottom = math.min(viewport.buf_line_count, cursor_line_00indexing + viewport.win_height)
  if bottom == 0 then
    bottom = -1
  end

  return { top, bottom }
end

function M.highlight(ev)
  local query = get_query()
  if not query then
    logger:debug("failed to get query")
    return
  end

  local viewport = get_viewport(ev.buf)
  if not viewport then
    logger:debug("failed to determine viewport for buf{%d}", ev.buf)
    return
  end

  local range = estimiate_highlight_range(viewport)
  local ns = vim.api.nvim_create_namespace(string.format("nvim-colors/%d", viewport.buf))

  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, viewport.buf, "colors")
  if not ok then
    return
  end

  local root = ltree:parse(range)[1]:root()

  -- Remove all marks in the buffer.
  vim.api.nvim_buf_clear_namespace(viewport.buf, ns, 0, -1)

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
      local hl_group = make_highlight_group(result)
      vim.api.nvim_buf_set_extmark(viewport.buf, ns, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        hl_group = hl_group,
      })
    end
  end
end

return M
