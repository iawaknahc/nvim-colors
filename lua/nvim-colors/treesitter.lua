local NS = vim.api.nvim_create_namespace("nvim-colors/treesitter")

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

--- @param bufnr integer
--- @return vim.treesitter.LanguageTree|nil
local function vim_treesitter_get_parser(bufnr)
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, bufnr, "colors")
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

---@param css_color_space string
---@return string
local function css_color_space_to_function_name(css_color_space)
  local lower = string.lower(css_color_space)
  local underscore = string.gsub(lower, "-", "_")
  return underscore
end

--- @param buf integer
--- @param capture_name string
--- @param tsnode TSNode
--- @param text string
--- @return color|nil
local function tsnode_to_color(buf, capture_name, tsnode, text)
  local csscolor4 = require("nvim-colors.csscolor4")

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
      return csscolor4[css_color_space_to_function_name(function_name)](L, a, b, alpha)
    elseif node_type == "css_function_lch" or node_type == "css_function_oklch" then
      local function_name = get_field_text(buf, tsnode, "function_name") --[[@as string]]
      local L = get_field_text(buf, tsnode, "L") --[[@as string]]
      local C = get_field_text(buf, tsnode, "C") --[[@as string]]
      local h = get_field_text(buf, tsnode, "h") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[css_color_space_to_function_name(function_name)](L, C, h, alpha)
    elseif node_type == "css_function_color_rgb" then
      local color_space = get_field_text(buf, tsnode, "color_space") --[[@as string]]
      local r = get_field_text(buf, tsnode, "r") --[[@as string]]
      local g = get_field_text(buf, tsnode, "g") --[[@as string]]
      local b = get_field_text(buf, tsnode, "b") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[css_color_space_to_function_name(color_space)](r, g, b, alpha)
    elseif node_type == "css_function_color_xyz" then
      local color_space = get_field_text(buf, tsnode, "color_space") --[[@as string]]
      local x = get_field_text(buf, tsnode, "x") --[[@as string]]
      local y = get_field_text(buf, tsnode, "y") --[[@as string]]
      local z = get_field_text(buf, tsnode, "z") --[[@as string]]
      local alpha = get_field_text(buf, tsnode, "alpha")
      return csscolor4[css_color_space_to_function_name(color_space)](x, y, z, alpha)
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

---@param bufnr integer
local function highlighter_destroy(bufnr)
  local ltree = vim_treesitter_get_parser(bufnr)
  if ltree ~= nil then
    ltree:destroy()
  end
end

---@param viewport { fg: color, bg: color, bufnr: integer, range_end_exclusive: Range4 }
local function highlighter_on_range(viewport)
  local query = vim_treesitter_query_get()
  local ltree = vim_treesitter_get_parser(viewport.bufnr)
  if query == nil or ltree == nil then
    return
  end

  local css = require("nvim-colors.css")

  -- NOTE: :parse() could be slow on a file like this,
  -- even the given range is small.
  -- https://github.com/justinmk/notes/blob/master/delicious.md
  -- https://github.com/neovim/neovim/issues/22426
  local root = ltree:parse(viewport.range_end_exclusive)[1]:root()

  -- NOTE: iter_captures could be slow on long lines.
  -- https://github.com/neovim/neovim/issues/22426
  -- https://github.com/neovim/neovim/issues/14756
  -- https://github.com/neovim/neovim/pull/15405
  -- Neovim 0.12 finally supports opts.start_col and opts.end_col
  for id, node, _, _ in
    query:iter_captures(
      root,
      viewport.bufnr,
      viewport.range_end_exclusive[1],
      viewport.range_end_exclusive[3],
      { start_col = viewport.range_end_exclusive[2], end_col = viewport.range_end_exclusive[4] }
    )
  do
    local capture_name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    local text = vim.treesitter.get_node_text(node, viewport.bufnr)
    local css_color = tsnode_to_color(viewport.bufnr, capture_name, node, text)
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
        vim.api.nvim_set_hl(NS, hl_group, {
          fg = result.highlight_fg,
          bg = result.highlight_bg,
        })
        vim.api.nvim_buf_set_extmark(viewport.bufnr, NS, start_row, start_col, {
          end_row = end_row,
          end_col = end_col,
          hl_group = hl_group,
          ephemeral = true,
        })
      end
    end
  end
end

---@param bufnr integer
function M.buf_disable(bufnr)
  vim.b[bufnr].nvimcolors_enabled = false
  vim.api.nvim__redraw({ buf = bufnr, valid = false })
end

---@param bufnr integer
function M.buf_enable(bufnr)
  vim.b[bufnr].nvimcolors_enabled = true
  vim.api.nvim__redraw({ buf = bufnr, valid = false })
end

---@param _ev vim.api.keyset.create_autocmd.callback_args
---@return boolean
local function enabled_func_default(_ev)
  return true
end

---@param ev vim.api.keyset.create_autocmd.callback_args
function M.autocmd_callback_attach(ev)
  -- Calling vim.treesitter.get_parser directly inside the callback of BufNew
  -- will cause BufReadPost not to fire.
  -- So we delay the call to vim.treesitter.get_parser with vim.schedule.
  -- A caveat is that ev.buf may become invalid or unloaded.
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(ev.buf) and vim.api.nvim_buf_is_loaded(ev.buf) then
      highlighter_destroy(ev.buf)
      local enabled_func = (vim.g.nvim_colors or {}).enabled or enabled_func_default
      vim.b[ev.buf].nvimcolors_enabled = enabled_func(ev)
    end
  end)
end

---@param ev vim.api.keyset.create_autocmd.callback_args
function M.autocmd_callback_detach(ev)
  highlighter_destroy(ev.buf)
  vim.b[ev.buf].nvimcolors_enabled = nil
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
    local css = require("nvim-colors.css")
    local fg, bg = css.get_fg_bg_from_colorscheme()
    highlighter_on_range({
      fg = fg,
      bg = bg,
      bufnr = bufnr,
      range_end_exclusive = { begin_row, begin_col, end_row, end_col },
    })
  end
end

return M
