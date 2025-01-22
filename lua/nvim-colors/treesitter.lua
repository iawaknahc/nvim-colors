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
      result = convert_css_color({
        color = text,
        fg_color = viewport.fg,
        bg_color = viewport.bg,
      })
    elseif capture_name == "colors.u32_argb" then
      result = convert_css_color({
        color = convert_u32_argb_to_css(text),
        fg_color = viewport.fg,
        bg_color = viewport.bg,
      })
    end

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

function M.setup()
  local ns = vim.api.nvim_create_namespace("nvim-colors")
  -- Enable our namespace.
  -- This is actually not very important since we also call
  -- nvim_win_set_hl_ns() and nvim_set_hl_ns_fast()
  vim.api.nvim_set_hl_ns(ns)

  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, winid, bufnr, toprow, botrow)
      -- TODO: Optimize the performance of large single line file.
      -- We do not do this because neovim itself has performance problem.
      -- See https://github.com/neovim/neovim/issues/22426
      -- As we depend on the performance of treesitter,
      -- there is little benefit we do any optimization now.

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

      highlight_viewport(ns, viewport)
    end,
  })
end

return M
