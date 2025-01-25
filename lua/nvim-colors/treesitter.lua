local bit = require("bit")

local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

local M = {}

local function vim_treesitter_query_get()
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

local function vim_treesitter_get_parser(buf)
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

local function range4_contains(range1, range2)
  local result = range1[1] <= range2[1]
    and range1[2] <= range2[2]
    and range1[3] >= range2[3]
    and range1[4] >= range2[4]
  return result
end

local function highlight_viewport(highlighter, viewport)
  local query = highlighter.query
  local ltree = highlighter.ltree
  local ns = highlighter.ns

  local line_range = viewport.line_range

  -- NOTE: This is fast, even on very long line.
  local root = ltree:trees()[1]:root()

  -- NOTE: This is slow on very long line.
  -- The reason is that iter_captures does not support column filter.
  -- https://github.com/neovim/neovim/issues/22426
  -- https://github.com/neovim/neovim/issues/14756
  -- https://github.com/neovim/neovim/pull/15405
  for id, node, _metadata, _match in
    query:iter_captures(root, viewport.bufnr, viewport.line_range[1], viewport.line_range[1] + 1)
  do
    local capture_name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()
    local node_range = { start_row, start_col, end_row, end_col }

    if range4_contains(line_range, node_range) then
      local css = tsnode_to_css(viewport.bufnr, capture_name, node)
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
          vim.api.nvim_buf_set_extmark(viewport.bufnr, ns, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            hl_group = hl_group,
            ephemeral = true,
          })
        end
      end
    end
  end
end

local function get_byte_count_in_row(bufnr, row)
  local byte_count_including_eol = vim.api.nvim_buf_get_offset(bufnr, row + 1)
    - vim.api.nvim_buf_get_offset(bufnr, row)

  return byte_count_including_eol
end

local function on_win_impl(winid, bufnr, toprow, botrow)
  local getwininfo_result = vim.fn.getwininfo(winid)[1]
  local width = getwininfo_result.width - getwininfo_result.textoff
  local height = getwininfo_result.height
  local cell_count = width * height

  -- leftcol is returned in getwininfo on Neovim >= 0.11
  local leftcol = 0
  if vim.api.nvim_get_current_win() == winid then
    local winsaveview_result = vim.fn.winsaveview()
    leftcol = winsaveview_result.leftcol
  end

  local cursor_position_ = vim.api.nvim_win_get_cursor(winid)
  local cursor_position = { cursor_position_[1] - 1, cursor_position_[2] }
  local wrap = vim.wo[winid].wrap

  -- UTF-8 character is at most 4-byte.
  local multiplier = 4

  local line_range_list = {}
  local line_range_table = {}
  for row = toprow, botrow do
    local byte_count = get_byte_count_in_row(bufnr, row)

    local line_range = nil
    if wrap then
      -- If it is not the cursor row, the cursor is like at the 0 column.
      local cursor_col = 0

      local is_cursor_row = cursor_position[1] == row
      if is_cursor_row then
        -- It is the cursor row, we need to consider the horizontal scroll offset.
        cursor_col = cursor_position[2]
      end

      -- Assuming the cursor is at the bottom-right of the screen,
      -- the byte at the top-left of the screen is cursor_col - 4-byte * cell_count
      local minimum_start_col = math.max(0, cursor_col - multiplier * cell_count)
      -- Assuming the cursor is at the top-left of the screen,
      -- the byte at the bottom-right of the screen is cursor_col + 4-byte * cell_count
      local maximum_end_col = math.min(byte_count, cursor_col + multiplier * cell_count)
      line_range = { row, minimum_start_col, row, maximum_end_col }
    else
      -- Assume the worst case.
      -- All characters are 4-byte and they are shown as 1 cell.
      -- To fill the whole line, we need width * 4 bytes.
      local worst_case_byte_count = multiplier * width
      line_range = {
        row,
        math.max(0, leftcol - worst_case_byte_count),
        row,
        math.min(byte_count, (leftcol + worst_case_byte_count)),
      }
    end

    table.insert(line_range_list, line_range)
    line_range_table[row] = line_range
  end

  local parse_range = { 0, 0, 0, 0 }
  if #line_range_list > 0 then
    local first_line_range = line_range_list[1]
    local last_line_range = line_range_list[#line_range_list]
    parse_range =
      { first_line_range[1], first_line_range[2], last_line_range[3], last_line_range[4] }
  end

  return parse_range, line_range_table
end

function M.setup()
  local ns = vim.api.nvim_create_namespace("nvim-colors")
  local augroup = vim.api.nvim_create_augroup("nvim-colors", {})
  -- Enable our namespace.
  -- This is actually not very important since we also call
  -- nvim_win_set_hl_ns() and nvim_set_hl_ns_fast()
  vim.api.nvim_set_hl_ns(ns)

  local highlighters = {}

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
      -- Calling vim.treesitter.get_parser directly inside the callback of BufNew
      -- will cause BufReadPost not to fire.
      -- So we delay the call to vim.treesitter.get_parser with vim.schedule.
      vim.schedule(function()
        local bufnr = ev.buf
        local highlighter = highlighters[bufnr]
        if highlighter ~= nil then
          highlighter.ltree:destroy()
          highlighters[bufnr] = nil
        end

        local query = vim_treesitter_query_get()
        local ltree = vim_treesitter_get_parser(bufnr)
        if query ~= nil and ltree ~= nil then
          highlighter = {
            query = query,
            ltree = ltree,
            ns = ns,
            viewport = {},
          }
          highlighters[bufnr] = highlighter
        end
      end)
    end,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({ "BufUnload" }, {
    callback = function(ev)
      local bufnr = ev.buf
      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter.ltree:destroy()
        highlighters[bufnr] = nil
      end
    end,
    group = augroup,
  })

  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, winid, bufnr, toprow, botrow)
      -- toprow and botrow are 0-indexing, end-inclusive.
      local highlighter = highlighters[bufnr]
      if highlighter == nil then
        return
      end

      local fg, bg = get_fg_bg_from_colorscheme()

      highlighter.viewport[winid] = {}
      local parse_range, line_ranges = on_win_impl(winid, bufnr, toprow, botrow)
      local ltree = highlighter.ltree
      -- NOTE: Performance of ltree:parse()
      -- When there is no injection, then it is fast even on very long line.
      local _ = ltree:parse(parse_range)[1]
      for row, line_range in pairs(line_ranges) do
        highlighter.viewport[winid][row] = {
          fg = fg,
          bg = bg,
          bufnr = bufnr,
          parse_range = parse_range,
          line_range = line_range,
        }
      end

      -- Enable our highlight namespace in the window.
      -- For windows showing normal buffers, this is enough.
      vim.api.nvim_win_set_hl_ns(winid, ns)

      -- If we do not call nvim_set_hl_ns_fast(), then
      -- the namespace may not appear to be active in some windows,
      -- notably the preview window of fzf-lua, and the completion menu of blink.cmp
      -- So this line is extremely important.
      vim.api.nvim_set_hl_ns_fast(ns)
    end,
    on_line = function(_, winid, bufnr, row)
      local highlighter = highlighters[bufnr]
      if highlighter == nil then
        return
      end

      local a = highlighter.viewport[winid]
      if a == nil then
        return
      end
      local viewport = a[row]
      if viewport == nil then
        return
      end

      highlight_viewport(highlighter, viewport)
    end,
  })
end

return M
