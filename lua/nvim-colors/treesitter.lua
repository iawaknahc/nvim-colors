local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

local CSS_COLOR_TO_CANONICAL_CACHE = {}
local CANONICAL_TO_CONVERSION_RESULT_CACHE = {}

local M = {}

local function get_query()
  local query = vim.treesitter.query.get("colors", "colors")
  if not query then
    logger:error("query not found")
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

function M.attach_to_buffer(bufnr)
  local group = vim.api.nvim_create_augroup("nvim-colors", {})
  local ns = vim.api.nvim_create_namespace(string.format("nvim-colors/%d", bufnr))

  local function draw()
    local query = get_query()
    if not query then
      return
    end

    local ltree = vim.treesitter.get_parser(bufnr, "colors")
    local root = ltree:parse(true)[1]:root()

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    vim.api.nvim_set_hl_ns(ns)

    for id, node, _metadata, _match in query:iter_captures(root, bufnr) do
      local capture_name = query.captures[id]
      local start_row, start_col, end_row, end_col = node:range()
      local text = vim.treesitter.get_node_text(node, bufnr)

      local result = nil
      if capture_name == "colors.css" then
        result = convert_css_color(text)
      elseif capture_name == "colors.u32_argb" then
        local css_color = convert_u32_argb_to_css(text)
        result = convert_css_color(css_color)
      end

      if result then
        local hl_group = make_highlight_group(ns, result)
        vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, start_col, {
          end_row = end_row,
          end_col = end_col,
          hl_group = hl_group,
        })
      end
    end
  end

  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if not vim.api.nvim_buf_is_loaded(bufnr) then
        return true
      end

      draw()
    end,
  })

  draw()
end

return M
