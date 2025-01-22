local bit = require("bit")

local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

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

local function base10_to_rrggbb(base10)
  return "#" .. bit.tohex(base10, 6)
end

local function get_fg_bg_from_colorscheme()
  -- Our defaults.
  local fg_base10 = 16777215 -- this is 0xffffff in base10.
  local bg_base10 = 0 -- this is 0x000000 in base10.

  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if normal.fg ~= nil then
    fg_base10 = normal.fg
  end
  if normal.bg ~= nil then
    bg_base10 = normal.bg
  end

  -- Convert base10 to #rrggbb
  local fg = base10_to_rrggbb(fg_base10)
  local bg = base10_to_rrggbb(bg_base10)

  return fg, bg
end

local CSS_COLOR_CACHE = {}
local function get_css_color_cache_key(input)
  return input.color .. ":" .. input.fg_color .. ":" .. input.bg_color
end
local function convert_css_color(input)
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

local function convert_u32_argb_to_css(u32_argb)
  local argb = string.gsub(string.gsub(string.lower(u32_argb), "_", ""), "0x", "")
  local a = string.sub(argb, 1, 2)
  local rgb = string.sub(argb, 3, 9)
  return "#" .. rgb .. a
end

local function get_nvim_hl_group_name(conversion_result)
  return string.format(
    "nvim_colors_%s_%s",
    string.gsub(conversion_result.highlight_fg, "#", ""),
    string.gsub(conversion_result.highlight_bg, "#", "")
  )
end

local function get_field_text(buf, tsnode, field_name)
  local tsnodes_field = tsnode:field(field_name)
  if #tsnodes_field > 0 then
    local text = vim.treesitter.get_node_text(tsnodes_field[1], buf)
    -- colorjs.io does not handle the keyword none case sensitively,
    -- so we lowercase the text.
    text = string.lower(text)
    return text
  end
end

local function _tsnode_to_css(buf, capture_name, tsnode, text)
  if capture_name == "colors.css" then
    local node_type = tsnode:type()
    if node_type == "css_hex_color" then
      return text
    elseif node_type == "css_named_color" then
      return text
    elseif node_type == "css_keyword_transparent" then
      return text
    elseif node_type == "css_function_rgb" or node_type == "css_function_rgba" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local r = get_field_text(buf, tsnode, "r")
      local g = get_field_text(buf, tsnode, "g")
      local b = get_field_text(buf, tsnode, "b")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s / %s)", function_name, r, g, b, alpha)
      else
        return string.format("%s(%s %s %s)", function_name, r, g, b)
      end
    elseif node_type == "css_function_hsl" or node_type == "css_function_hsla" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local h = get_field_text(buf, tsnode, "h")
      local s = get_field_text(buf, tsnode, "s")
      local l = get_field_text(buf, tsnode, "l")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s / %s)", function_name, h, s, l, alpha)
      else
        return string.format("%s(%s %s %s)", function_name, h, s, l)
      end
    elseif node_type == "css_function_hwb" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local h = get_field_text(buf, tsnode, "h")
      local w = get_field_text(buf, tsnode, "w")
      local b = get_field_text(buf, tsnode, "b")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s / %s)", function_name, h, w, b, alpha)
      else
        return string.format("%s(%s %s %s)", function_name, h, w, b)
      end
    elseif node_type == "css_function_lab" or node_type == "css_function_oklab" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local L = get_field_text(buf, tsnode, "L")
      local a = get_field_text(buf, tsnode, "a")
      local b = get_field_text(buf, tsnode, "b")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s / %s)", function_name, L, a, b, alpha)
      else
        return string.format("%s(%s %s %s)", function_name, L, a, b)
      end
    elseif node_type == "css_function_lch" or node_type == "css_function_oklch" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local L = get_field_text(buf, tsnode, "L")
      local C = get_field_text(buf, tsnode, "C")
      local h = get_field_text(buf, tsnode, "h")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s / %s)", function_name, L, C, h, alpha)
      else
        return string.format("%s(%s %s %s)", function_name, L, C, h)
      end
    elseif node_type == "css_function_color_rgb" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local color_space = get_field_text(buf, tsnode, "color_space")
      local r = get_field_text(buf, tsnode, "r")
      local g = get_field_text(buf, tsnode, "g")
      local b = get_field_text(buf, tsnode, "b")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s %s / %s)", function_name, color_space, r, g, b, alpha)
      else
        return string.format("%s(%s %s %s %s)", function_name, color_space, r, g, b)
      end
    elseif node_type == "css_function_color_xyz" then
      local function_name = get_field_text(buf, tsnode, "function_name")
      local color_space = get_field_text(buf, tsnode, "color_space")
      local x = get_field_text(buf, tsnode, "x")
      local y = get_field_text(buf, tsnode, "y")
      local z = get_field_text(buf, tsnode, "z")
      local alpha = get_field_text(buf, tsnode, "alpha")
      if alpha ~= nil then
        return string.format("%s(%s %s %s %s / %s)", function_name, color_space, x, y, z, alpha)
      else
        return string.format("%s(%s %s %s %s)", function_name, color_space, x, y, z)
      end
    end
  elseif capture_name == "colors.u32_argb" then
    return convert_u32_argb_to_css(text)
  end
end

local CSS_TEXT_CACHE = {}
local function tsnode_to_css(buf, capture_name, tsnode)
  local text = vim.treesitter.get_node_text(tsnode, buf)
  local hit = CSS_TEXT_CACHE[text]
  if hit ~= nil then
    return hit
  end
  return _tsnode_to_css(buf, capture_name, tsnode, text)
end

local function highlight_viewport(highlighter, viewport)
  local query = highlighter.query
  local ltree = highlighter.ltree
  local ns = highlighter.ns

  local range = viewport.win_visible_range

  local root = ltree:parse(range)[1]:root()

  for id, node, _metadata, _match in query:iter_captures(root, viewport.buf, range[1], range[2]) do
    local capture_name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()
    local css = tsnode_to_css(viewport.buf, capture_name, node)
    if css then
      local result = convert_css_color({
        color = css,
        fg_color = viewport.fg,
        bg_color = viewport.bg,
      })
      if result then
        local hl_group = get_nvim_hl_group_name(result)
        -- Based on observation, we do not cache the calls to nvim_set_hl()
        -- It must be called in each draw cycle.
        vim.api.nvim_set_hl(ns, hl_group, {
          fg = result.highlight_fg,
          bg = result.highlight_bg,
        })
        vim.api.nvim_buf_set_extmark(viewport.buf, ns, start_row, start_col, {
          end_row = end_row,
          end_col = end_col,
          hl_group = hl_group,
          ephemeral = true,
        })
      end
    end
  end
end

function M.setup()
  local ns = vim.api.nvim_create_namespace("nvim-colors")
  -- Enable our namespace.
  -- This is actually not very important since we also call
  -- nvim_win_set_hl_ns() and nvim_set_hl_ns_fast()
  vim.api.nvim_set_hl_ns(ns)

  local highlighters = {}
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, winid, bufnr, toprow, botrow)
      -- TODO: Optimize the performance of large single line file.
      -- We do not do this because neovim itself has performance problem.
      -- See https://github.com/neovim/neovim/issues/22426
      -- As we depend on the performance of treesitter,
      -- there is little benefit we do any optimization now.

      local highlighter = highlighters[bufnr]
      if highlighter == nil then
        local query = get_query()
        local ltree = get_ltree(bufnr)
        highlighter = {
          query = query,
          ltree = ltree,
          ns = ns,
        }
        highlighters[bufnr] = highlighter
      end

      local fg, bg = get_fg_bg_from_colorscheme()

      -- toprow and botrow are 0-indexing, end-inclusive.
      local viewport = {
        buf = bufnr,
        win = winid,
        win_visible_range = { toprow, botrow + 1 },
        fg = fg,
        bg = bg,
      }

      -- Enable our highlight namespace in the window.
      -- For windows showing normal buffers, this is enough.
      vim.api.nvim_win_set_hl_ns(winid, ns)

      -- If we do not call nvim_set_hl_ns_fast(), then
      -- the namespace may not appear to be active in some windows,
      -- notably the preview window of fzf-lua, and the completion menu of blink.cmp
      -- So this line is extremely important.
      vim.api.nvim_set_hl_ns_fast(ns)

      highlight_viewport(highlighter, viewport)
    end,
  })
end

return M
