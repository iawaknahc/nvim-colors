local logging = require("nvim-colors.logging")
local csscolor4 = require("nvim-colors.csscolor4")
local css = require("nvim-colors.css")
local tailwindcss = require("nvim-colors.tailwindcss")

local logger = logging.new({ name = "nvim-colors", level = logging.INFO })

local M = {}

--- @return vim.treesitter.Query|nil
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

--- @param buf integer
--- @return vim.treesitter.LanguageTree|nil
local function vim_treesitter_get_parser(buf)
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, buf, "colors")
  if not ok then
    return
  end

  return ltree
end

--- @param result ConvertCSSColorResult
--- @return string
local function get_nvim_hl_group_name(result)
  return string.format(
    "nvim_colors_treesitter_%s_%s",
    string.gsub(result.highlight_fg, "#", ""),
    string.gsub(result.highlight_bg, "#", "")
  )
end

--- @param u32_argb string
--- @return string
local function convert_u32_argb_to_css(u32_argb)
  local argb = string.gsub(string.gsub(string.lower(u32_argb), "_", ""), "0x", "")
  local a = string.sub(argb, 1, 2)
  local rgb = string.sub(argb, 3, 9)
  return "#" .. rgb .. a
end

--- @param buf integer
--- @param field_name string
--- @return string|nil
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

--- @param buf integer
--- @param capture_name string
--- @param tsnode TSNode
--- @param tw_theme_colors TailwindcssThemeColors
--- @param text string
--- @return color|nil
local function tsnode_to_color(buf, capture_name, tsnode, tw_theme_colors, text)
  if capture_name == "colors.css" then
    local node_type = tsnode:type()
    if node_type == "css_hex_color" then
      return csscolor4.hex(text)
    elseif node_type == "css_named_color" then
      return csscolor4.named_color(text)
    elseif node_type == "css_keyword_transparent" then
      return csscolor4.named_color(text)
    elseif node_type == "css_function_rgb" or node_type == "css_function_rgba" then
      local r = get_field_text(buf, tsnode, "r") --[[@as string]]
      local g = get_field_text(buf, tsnode, "g") --[[@as string]]
      local b = get_field_text(buf, tsnode, "b") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4.rgb(r, g, b, alpha)
    elseif node_type == "css_function_hsl" or node_type == "css_function_hsla" then
      local h = get_field_text(buf, tsnode, "h") --[[@as string]]
      local s = get_field_text(buf, tsnode, "s") --[[@as string]]
      local l = get_field_text(buf, tsnode, "l") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4.hsl(h, s, l, alpha)
    elseif node_type == "css_function_hwb" then
      local h = get_field_text(buf, tsnode, "h") --[[@as string]]
      local w = get_field_text(buf, tsnode, "w") --[[@as string]]
      local b = get_field_text(buf, tsnode, "b") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4.hwb(h, w, b, alpha)
    elseif node_type == "css_function_lab" or node_type == "css_function_oklab" then
      local function_name = get_field_text(buf, tsnode, "function_name") --[[@as string]]
      local L = get_field_text(buf, tsnode, "L") --[[@as string]]
      local a = get_field_text(buf, tsnode, "a") --[[@as string]]
      local b = get_field_text(buf, tsnode, "b") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[string.lower(function_name)](L, a, b, alpha)
    elseif node_type == "css_function_lch" or node_type == "css_function_oklch" then
      local function_name = get_field_text(buf, tsnode, "function_name") --[[@as string]]
      local L = get_field_text(buf, tsnode, "L") --[[@as string]]
      local C = get_field_text(buf, tsnode, "C") --[[@as string]]
      local h = get_field_text(buf, tsnode, "h") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[string.lower(function_name)](L, C, h, alpha)
    elseif node_type == "css_function_color_rgb" then
      local color_space = get_field_text(buf, tsnode, "color_space") --[[@as string]]
      local r = get_field_text(buf, tsnode, "r") --[[@as string]]
      local g = get_field_text(buf, tsnode, "g") --[[@as string]]
      local b = get_field_text(buf, tsnode, "b") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[string.lower(color_space)](r, g, b, alpha)
    elseif node_type == "css_function_color_xyz" then
      local color_space = get_field_text(buf, tsnode, "color_space") --[[@as string]]
      local x = get_field_text(buf, tsnode, "x") --[[@as string]]
      local y = get_field_text(buf, tsnode, "y") --[[@as string]]
      local z = get_field_text(buf, tsnode, "z") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[string.lower(color_space)](x, y, z, alpha)
    end
  elseif capture_name == "colors.u32_argb" then
    return csscolor4.hex(convert_u32_argb_to_css(text))
  elseif capture_name == "colors.tailwindcss" then
    return nil
    -- local node_type = tsnode:type()
    -- if node_type == "tailwindcss_color_classname_without_alpha" then
    --   local color_name = tailwindcss.tailwindcss_color_classname_without_alpha(text)
    --   if color_name ~= nil then
    --     return tw_theme_colors[color_name]
    --   end
    -- elseif node_type == "tailwindcss_color_classname_with_alpha_percentage" then
    --   local color_name, alpha = tailwindcss.tailwindcss_color_classname_with_alpha_percentage(text)
    --   if color_name ~= nil and alpha ~= nil then
    --     return tw_theme_colors[color_name], alpha
    --   end
    -- elseif node_type == "tailwindcss_color_classname_with_alpha_arbitrary_value" then
    --   local color_name, alpha = tailwindcss.tailwindcss_color_classname_with_alpha_arbitrary_value(text)
    --   if color_name ~= nil and alpha ~= nil then
    --     return tw_theme_colors[color_name], alpha
    --   end
    -- elseif node_type == "tailwindcss_color_css_variable_without_alpha" then
    --   local color_name = tailwindcss.tailwindcss_color_css_variable_without_alpha(text)
    --   if color_name ~= nil then
    --     return tw_theme_colors[color_name]
    --   end
    -- elseif node_type == "tailwindcss_color_css_variable_with_alpha" then
    --   local css_variable = get_field_text(buf, tsnode, "css_variable")
    --   local alpha_str = get_field_text(buf, tsnode, "alpha")
    --   if css_variable ~= nil then
    --     local color_name = tailwindcss.tailwindcss_color_css_variable_without_alpha(css_variable)
    --     if alpha_str ~= nil then
    --       return tw_theme_colors[color_name], tailwindcss.arbitrary_value_to_alpha(alpha_str)
    --     end
    --   end
    -- end
  end
end

---@param range1 Range4
---@param range2 Range4
---@return boolean
local function range4_contains(range1, range2)
  local result = range1[1] <= range2[1] and range1[2] <= range2[2] and range1[3] >= range2[3] and range1[4] >= range2[4]
  return result
end

--- @param bufnr integer
--- @param row integer
--- @return integer
local function get_byte_count_in_row(bufnr, row)
  local byte_count_including_eol = vim.api.nvim_buf_get_offset(bufnr, row + 1) - vim.api.nvim_buf_get_offset(bufnr, row)
  return byte_count_including_eol
end

---@param winid integer
---@param bufnr integer
---@param toprow integer
---@param botrow integer
---@return { [integer]: Range4 }
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

  --- @type Range4[]
  local line_range_list = {}
  --- @type { [integer]: Range4 }
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

  return line_range_table
end

---@class TreesitterViewport
---@field fg color
---@field bg color
---@field bufnr integer
---@field line_range Range4
local TreesitterViewport = {}

--- @class (exact) NewTreesitterHighlighterOptions
--- @field bufnr integer
--- @field ns integer
local NewTreesitterHighlighterOptions = {}

--- @class TreesitterHighlighter
--- @field private bufnr integer
--- @field private query vim.treesitter.Query
--- @field private ltree vim.treesitter.LanguageTree
--- @field private ns integer
--- @field enabled boolean
--- @field tw_theme_colors TailwindcssThemeColors
--- @field private viewport { [integer]: { [integer]: TreesitterViewport } }
local TreesitterHighlighter = {}
TreesitterHighlighter.__index = TreesitterHighlighter

--- @param options NewTreesitterHighlighterOptions
--- @return TreesitterHighlighter|nil
function TreesitterHighlighter.new(options)
  local query = vim_treesitter_query_get()
  local ltree = vim_treesitter_get_parser(options.bufnr)

  if query ~= nil and ltree ~= nil then
    local self = setmetatable({}, TreesitterHighlighter)
    self.bufnr = options.bufnr
    self.query = query
    self.ltree = ltree
    self.ns = options.ns
    self.enabled = true
    self.tw_theme_colors = tailwindcss.DEFAULT_THEME_COLORS
    self.viewport = {}
    return self
  end
end

function TreesitterHighlighter:destroy()
  self.ltree:destroy()
end

--- @param winid integer
--- @param toprow integer
--- @param botrow integer
function TreesitterHighlighter:on_win(winid, toprow, botrow)
  self.viewport[winid] = {}
  if self.enabled then
    local fg, bg = css.get_fg_bg_from_colorscheme()
    local line_ranges = on_win_impl(winid, self.bufnr, toprow, botrow)
    for row, line_range in pairs(line_ranges) do
      self.viewport[winid][row] = {
        fg = fg,
        bg = bg,
        bufnr = self.bufnr,
        line_range = line_range,
      }
    end
  end
end

--- @param winid integer
--- @param row integer
function TreesitterHighlighter:on_line(winid, row)
  local a = self.viewport[winid]
  if a ~= nil then
    local viewport = a[row]
    if viewport ~= nil then
      self:_highlight_viewport(viewport)
    end
  end
end

--- @param viewport TreesitterViewport
function TreesitterHighlighter:_highlight_viewport(viewport)
  local query = self.query
  local ltree = self.ltree
  local ns = self.ns
  local tw_theme_colors = self.tw_theme_colors

  local line_range = viewport.line_range

  -- NOTE: :parse() is very slow on a file like this,
  -- even the given range is small.
  -- https://github.com/justinmk/notes/blob/master/delicious.md
  -- https://github.com/neovim/neovim/issues/22426
  local root = ltree:parse(line_range)[1]:root()

  -- NOTE: This is slow on very long line.
  -- The reason is that iter_captures does not support column filter.
  -- https://github.com/neovim/neovim/issues/22426
  -- https://github.com/neovim/neovim/issues/14756
  -- https://github.com/neovim/neovim/pull/15405
  for id, node, _, _ in query:iter_captures(root, viewport.bufnr, viewport.line_range[1], viewport.line_range[1] + 1) do
    local capture_name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()
    local node_range = { start_row, start_col, end_row, end_col }

    if range4_contains(line_range, node_range) then
      local text = vim.treesitter.get_node_text(node, viewport.bufnr)
      local css_color = tsnode_to_color(viewport.bufnr, capture_name, node, tw_theme_colors, text)
      if css_color ~= nil then
        local result = css.convert_css_color({
          color = css_color,
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

---@type { [integer]: TreesitterHighlighter|nil }
local highlighters = {}

--- @param bufnr integer
function M.buf_disable(bufnr)
  local highlighter = highlighters[bufnr]
  if highlighter ~= nil then
    highlighter.enabled = false
  end
end

--- @param bufnr integer
function M.buf_enable(bufnr)
  local highlighter = highlighters[bufnr]
  if highlighter ~= nil then
    highlighter.enabled = true
  end
end

function M.setup()
  local augroup = vim.api.nvim_create_augroup("nvim-colors/treesitter", {})
  local ns = vim.api.nvim_create_namespace("nvim-colors/treesitter")

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
        --- @type integer
        local bufnr = ev.buf
        local highlighter = highlighters[bufnr]
        if highlighter ~= nil then
          highlighter:destroy()
          highlighters[bufnr] = nil
        end

        highlighter = TreesitterHighlighter.new({
          bufnr = bufnr,
          ns = ns,
        })
        if highlighter ~= nil then
          highlighters[bufnr] = highlighter
        end
      end)
    end,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({ "BufUnload" }, {
    callback = function(ev)
      --- @type integer
      local bufnr = ev.buf
      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter:destroy()
        highlighters[bufnr] = nil
      end
    end,
    group = augroup,
  })

  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, winid, bufnr, toprow, botrow)
      -- nvim_set_hl_ns_fast() is intended to be used with nvim_set_decoration_provider().
      -- With nvim_set_decoration_provider() and nvim_set_hl_ns_fast(),
      -- calling nvim_set_hl_ns() and nvim_win_set_hl_ns() are unnecessary.
      vim.api.nvim_set_hl_ns_fast(ns)

      -- Return false in on_win will skip on_line, but
      -- retain the extmarks created in a previous call.
      -- We want to behavior that if we do not call nvim_buf_set_extmark()
      -- then we expect no extmarks to be drawn.
      -- So we never return false in on_win or on_line.

      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter:on_win(winid, toprow, botrow)
      end
    end,
    on_line = function(_, winid, bufnr, row)
      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter:on_line(winid, row)
      end
    end,
  })
end

return M
