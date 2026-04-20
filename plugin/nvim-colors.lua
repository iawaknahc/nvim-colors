local AUGROUP = vim.api.nvim_create_augroup("nvimcolors", { clear = true })
local NS = vim.api.nvim_create_namespace("nvimcolors")

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

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = AUGROUP,
  callback = function(_ev)
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
  end,
})

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
    local enabled = vim.g.nvimcolors_enabled
    if enabled == nil then
      vim.b[ev.buf].nvimcolors_enabled = true
    elseif type(enabled) == "function" then
      vim.b[ev.buf].nvimcolors_enabled = enabled(ev)
    elseif type(enabled) == "boolean" then
      vim.b[ev.buf].nvimcolors_enabled = enabled
    else
      error(
        "vim.g.nvimcolors_enabled must be either nil, boolean, or a function taking autocmd event returning a boolean"
      )
    end
  end,
  group = AUGROUP,
})

vim.api.nvim_create_autocmd({ "BufUnload" }, {
  callback = function(ev)
    require("nvim-colors.impl_decoration_provider").autocmd(ev)
    vim.b[ev.buf].nvimcolors_enabled = nil
  end,
  group = AUGROUP,
})

vim.api.nvim_set_decoration_provider(NS, {
  on_start = function(_, displaytick)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_start(_, displaytick)
  end,
  on_buf = function(_, bufnr, displaytick)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_buf(_, bufnr, displaytick)
  end,
  on_win = function(_, winid, bufnr, toprow, botrow)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_win(_, winid, bufnr, toprow, botrow)
  end,
  -- on_range was introduced in Neovim 0.12
  -- Its primary user is the builtin treesitter highlight.
  -- It was an optimization over the deprecated on_line.
  -- See https://github.com/neovim/neovim/pull/31400
  on_range = function(_, winid, bufnr, begin_row, begin_col, end_row, end_col)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_range(
      _,
      winid,
      bufnr,
      begin_row,
      begin_col,
      end_row,
      end_col
    )
  end,
  on_end = function(_, displaytick)
    return require("nvim-colors.impl_decoration_provider").decoration_provider_on_end(_, displaytick)
  end,
})
