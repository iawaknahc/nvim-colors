local M = {}

---@return string
local function get_script_path()
  local this_function = 1
  local source = "S"
  local info = debug.getinfo(this_function, source)
  if info == nil then
    error("debug.getinfo returns nil")
  end
  if info.source:sub(1, 1) ~= "@" then
    error("info.source does not start with @: " .. info.source)
  end
  return info.source:sub(2)
end

---@param p string
---@param callback fun(err?: string, hash?: string)
local function file_sha256(p, callback)
  local mode = tonumber("444", 8) --[[@as integer]]
  vim.uv.fs_open(p, "r", mode, function(err, fd)
    if err ~= nil then
      callback(err, nil)
    elseif fd ~= nil then
      vim.uv.fs_stat(p, function(err, stat)
        if err ~= nil then
          callback(err, nil)
        elseif stat ~= nil then
          vim.uv.fs_read(fd, stat.size, nil, function(err, contents)
            if err ~= nil then
              callback(err, nil)
            elseif contents ~= nil then
              vim.schedule(function()
                local hash = vim.fn.sha256(contents)
                callback(nil, hash)
              end)
            end
          end)
        end
      end)
    end
  end)
end

local function build_and_make_parser_available()
  local ok, script_path = pcall(get_script_path)
  if not ok then
    vim.notify("Failed to get script path: " .. script_path, vim.log.levels.ERROR)
    return
  end

  local plugin_home = vim.fs.dirname(vim.fs.dirname(script_path))

  if vim.fn.executable("tree-sitter") == 0 then
    vim.notify("tree-sitter is not in your PATH", vim.log.levels.ERROR)
    return
  end

  local grammar_js = vim.fs.joinpath(plugin_home, "grammar.js")
  file_sha256(grammar_js, function(err, hash)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
    elseif hash ~= nil then
      local cache_dir = vim.fn.stdpath("cache") --[[@as string]]
      if type(cache_dir) ~= "string" then
        vim.notify([[vim.fn.stdpath("cache") does not return string]], vim.log.levels.ERROR)
        return
      end

      local runtime = vim.fs.joinpath(cache_dir, "nvimcolors", hash, "runtime")
      if vim.fn.mkdir(runtime, "p") == 0 then
        vim.notify("Failed to create " .. runtime, vim.log.levels.ERROR)
        return
      end

      local function prepend_runtime()
        vim.o.runtimepath = runtime .. "," .. vim.o.runtimepath
      end

      local parser = vim.fs.joinpath(runtime, "parser")
      if vim.fn.mkdir(parser, "p") == 0 then
        vim.notify("Failed to create " .. parser, vim.log.levels.ERROR)
        return
      end

      local parser_so = vim.fs.joinpath(parser, "nvimcolors.so")
      if vim.fn.filereadable(parser_so) == 0 then
        vim.system(
          { "tree-sitter", "generate", "--abi", "15" },
          { cwd = plugin_home, text = true },
          vim.schedule_wrap(function(out)
            if out.code ~= 0 then
              vim.notify("Failed to run tree-sitter generate: " .. out.stderr, vim.log.levels.ERROR)
              return
            end

            vim.system(
              { "tree-sitter", "build", "-o", parser_so },
              { cwd = plugin_home, text = true },
              vim.schedule_wrap(function(out)
                if out.code ~= 0 then
                  vim.notify("Failed to run tree-sitter build: " .. out.stderr, vim.log.levels.ERROR)
                  return
                end

                prepend_runtime()
              end)
            )
          end)
        )
      else
        prepend_runtime()
      end
    end
  end)
end

function M.build_and_make_parser_available_once()
  if vim.g.nvimcolors_build_and_make_parser_available_once_called == nil then
    vim.g.nvimcolors_build_and_make_parser_available_once_called = true
    build_and_make_parser_available()
  end
end

--- @return vim.treesitter.Query?
local function vim_treesitter_query_get()
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, query = pcall(vim.treesitter.query.get, "nvimcolors", "nvimcolors")
  if not ok then
    return
  end
  if not query then
    return
  end

  return query
end

--- @param bufnr integer
--- @return vim.treesitter.LanguageTree?
local function vim_treesitter_get_parser(bufnr)
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, bufnr, "nvimcolors")
  if not ok then
    return
  end

  return ltree
end

--- @param bufnr integer
--- @return vim.treesitter.LanguageTree?
function M.vim_treesitter_get_parser(bufnr)
  -- Nix perform checking at install time.
  -- The parser is not available at that moment.
  local ok, ltree = pcall(vim.treesitter.get_parser, bufnr, "nvimcolors")
  if not ok then
    return
  end

  return ltree
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
--- @return string?
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
  -- Convert "rgb(" to "rgb" and "a98-rgb" to "a98_rgb"
  local function_name = css_color_space:lower():gsub("-", "_"):gsub("%($", "")
  return function_name
end

--- @param buf integer
--- @param capture_name string
--- @param tsnode TSNode
--- @param text string
--- @return nvimcolors.css.color?
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
    -- TailwindCSS v4 removed resolveConfig.
    -- There is no easy way to get a resolved theme with all colors.
    return nil
  end
end

---@param bufnr integer
---@param ltree vim.treesitter.LanguageTree
---@param range_end_exclusive Range4
---@return fun(): { color: nvimcolors.css.color, range4: Range4 }
function M.iter_colors(bufnr, ltree, range_end_exclusive)
  return coroutine.wrap(function()
    local query = vim_treesitter_query_get()
    if query == nil then
      return
    end

    ltree:for_each_tree(function(tree, _)
      local root = tree:root()

      -- NOTE: iter_captures could be slow on long lines.
      -- https://github.com/neovim/neovim/issues/22426
      -- https://github.com/neovim/neovim/issues/14756
      -- https://github.com/neovim/neovim/pull/15405
      -- Neovim 0.12 finally supports opts.start_col and opts.end_col
      for id, node, _, _ in
        query:iter_captures(
          root,
          bufnr,
          range_end_exclusive[1],
          range_end_exclusive[3],
          { start_col = range_end_exclusive[2], end_col = range_end_exclusive[4] }
        )
      do
        local capture_name = query.captures[id]
        local start_row, start_col, end_row, end_col = node:range()

        -- For some unknown reason, when it is editing,
        -- get_node_text will include incorrect text.
        -- For example, when I am typing "red ",
        -- css_named_color is returned but the node text is "red ".
        local text = vim.treesitter.get_node_text(node, bufnr)
        local ok, css_color = pcall(tsnode_to_color, bufnr, capture_name, node, text)
        if ok and css_color ~= nil then
          coroutine.yield({
            color = css_color,
            range4 = { start_row, start_col, end_row, end_col },
          })
        end
      end
    end)
  end)
end

---@param bufnr integer
---@param callback fun(err?: string, colors: {color: nvimcolors.css.color, range4: Range4}[]?)
function M.find_all_colors_inefficiently_with_callback(bufnr, callback)
  local query = vim_treesitter_query_get()
  local ltree = vim_treesitter_get_parser(bufnr)
  if query == nil or ltree == nil then
  end

  ---@param trees table<integer, TSTree>
  local handle_trees = function(trees)
    local out = {}

    local root = trees[1]:root()
    for id, node, _, _ in query:iter_captures(root, bufnr) do
      local capture_name = query.captures[id]
      local start_row, start_col, end_row, end_col = node:range()

      local text = vim.treesitter.get_node_text(node, bufnr)
      local css_color = tsnode_to_color(bufnr, capture_name, node, text)
      if css_color ~= nil then
        table.insert(out, {
          color = css_color,
          range4 = { start_row, start_col, end_row, end_col },
        })
      end
    end

    callback(nil, out)
  end

  local trees_returned_synchronously = ltree:parse(true, function(err, trees_returned_asynchronously)
    if err ~= nil then
      callback(err, nil)
    end
    if trees_returned_asynchronously ~= nil then
      handle_trees(trees_returned_asynchronously)
    end
  end)

  if trees_returned_synchronously ~= nil then
    handle_trees(trees_returned_synchronously)
  end
end

return M
