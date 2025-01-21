local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

local plugin_ns = vim.api.nvim_create_namespace("nvim-colors")

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

local function get_viewports(buf)
  local viewports = {}

  local tabpages = vim.api.nvim_list_tabpages()
  for _, tabpage in ipairs(tabpages) do
    local windows = vim.api.nvim_tabpage_list_wins(tabpage)
    for _, win in pairs(windows) do
      local that_buf = vim.api.nvim_win_get_buf(win)
      if that_buf == buf then
        -- :h line()
        local first_visible_line_1indexing = vim.fn.line("w0", win)
        local last_visible_line_1indexing = vim.fn.line("w$", win)
        if first_visible_line_1indexing ~= 0 and last_visible_line_1indexing ~= 0 then
          local no_lines_are_visible = last_visible_line_1indexing
            == first_visible_line_1indexing - 1
          if not no_lines_are_visible then
            table.insert(viewports, {
              tabpage = tabpage,
              win = win,
              win_height = vim.api.nvim_win_get_height(win),
              win_visible_range = {
                -- minus 1 to make it 0-indexing.
                first_visible_line_1indexing - 1,
                -- minus 1 to make it 0-indexing.
                -- plus 1 to make it exclusive.
                last_visible_line_1indexing
                  - 1
                  + 1,
              },
              buf = buf,
            })
          end
        end
      end
    end
  end

  return viewports
end

local function highlight_viewport(viewport)
  local query = get_query()
  if not query then
    return
  end

  local range = viewport.win_visible_range
  local ns = vim.api.nvim_create_namespace(string.format("nvim-colors/%d", viewport.buf))

  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, viewport.buf, "colors")
  if not ok then
    return
  end

  local root = ltree:parse(range)[1]:root()

  -- Remove the marks in visible range.
  vim.api.nvim_buf_clear_namespace(viewport.buf, ns, range[1], range[2])

  -- Enable our highlight namespace in the window.
  -- Some plugin such as blink.cmp set the option 'winhighlight'.
  -- We need to use nvim_win_set_hl_ns to override.
  vim.api.nvim_win_set_hl_ns(viewport.win, plugin_ns)

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

function M.highlight(ev)
  if ev.event == "BufWinEnter" then
    -- In BufWinEnter, only buf is available.
    -- But we do not know which window it is in.
    -- So the best effort is process all windows that are showing this buffer.
    -- You may wonder why we do not use nvim_get_current_win() here.
    -- It is because blink.cmp uses window and buffer to show the completion menu.
    -- So nvim_get_current_win() is the window of the editing file, not the window containing the completion menu.
    local viewports = get_viewports(ev.buf)
    for _, viewport in ipairs(viewports) do
      highlight_viewport(viewport)
    end
  elseif
    ev.event == "InsertLeave"
    or ev.event == "TextChanged"
    or ev.event == "TextChangedI"
    or ev.event == "TextChangedP"
  then
    -- In these events, we assume that nvim_get_current_win() is the window showing the buffer.
    -- This should be a fair assumption because these events are fired by buftype="" buffers (i.e. normal buffers)
    -- We ignore other windows showing the same buffer.
    local viewports = get_viewports(ev.buf)
    for _, viewport in ipairs(viewports) do
      if viewport.win == vim.api.nvim_get_current_win() then
        highlight_viewport(viewport)
      end
    end
  elseif ev.event == "WinScrolled" or ev.event == "WinResized" then
    -- In these events, the window-id is available as ev.file or ev.match
    -- So we can use them directly.
    local win = tonumber(ev.match)
    local viewports = get_viewports(ev.buf)
    for _, viewport in ipairs(viewports) do
      if viewport.win == win then
        highlight_viewport(viewport)
      end
    end
  else
    -- Ignore other events we do not know.
  end
end

M.EVENTS = {
  "BufWinEnter",
  "InsertLeave",
  "TextChanged",
  "TextChangedI",
  "TextChangedP",
  "WinScrolled",
  "WinResized",
}

return M
