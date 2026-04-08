local M = {}

---@param color nvimcolors.css.color
---@return lsp.Color
local function css_color_to_lsp_color(color)
  local csscolor4 = require("nvim-colors.csscolor4")
  local mapped = csscolor4.css_gamut_map(color, "srgb")

  local red = mapped[2][1]
  if type(red) ~= "number" or red < 0 or red > 1 then
    red = 0
  end

  local green = mapped[2][2]
  if type(green) ~= "number" or green < 0 or green > 1 then
    green = 0
  end

  local blue = mapped[2][3]
  if type(blue) ~= "number" or blue < 0 or blue > 1 then
    blue = 0
  end

  local alpha = mapped[3]
  if type(alpha) ~= "number" or alpha < 0 or alpha > 1 then
    alpha = nil
  end

  ---@type lsp.Color
  local lsp_color = {
    red = red,
    green = green,
    blue = blue,
    alpha = alpha,
  }

  return lsp_color
end

---@param bufnr integer
---@param range4 Range4
---@return lsp.Range
local function range4_to_lsp_range(bufnr, range4)
  local range = vim.range(range4[1], range4[2], range4[3], range4[4], { buf = bufnr })
  return range:to_lsp("utf-8")
end

---@param bufnr integer
---@param colors { color: nvimcolors.css.color, range4: Range4 }[]
---@return lsp.ColorInformation[]
local function to_lsp_color_information(bufnr, colors)
  local out = {}
  for _, color_with_range in ipairs(colors) do
    ---@type lsp.ColorInformation
    local color_information = {
      color = css_color_to_lsp_color(color_with_range.color),
      range = range4_to_lsp_range(bufnr, color_with_range.range4),
    }
    table.insert(out, color_information)
  end
  return out
end

---@param dispatchers vim.lsp.rpc.Dispatchers
---@param _config vim.lsp.ClientConfig
---@return vim.lsp.rpc.PublicClient
function M.new_client(dispatchers, _config)
  local closed = false
  local message_id = 0

  return {
    ---@param method vim.lsp.protocol.Method.ClientToServer.Request
    ---@param params table?
    ---@param callback fun(err?: lsp.ResponseError, result: unknown)
    ---@param _notify_reply_callback fun(message_id: integer)
    ---@return boolean, integer?
    request = function(method, params, callback, _notify_reply_callback)
      message_id = message_id + 1
      local id = message_id
      if method == "initialize" then
        callback(nil, {
          capabilities = {
            positionEncoding = "utf-8",
            colorProvider = true,
          },
          serverInfo = {
            name = "nvim-colors",
          },
        })
      elseif method == "shutdown" then
        callback(nil, vim.NIL)
      elseif method == "textDocument/documentColor" then
        -- FIXME: This implementation is currently broken.

        -- In LSP 3.17, textDocument/documentColor does not support range.
        -- So the LSP server is required to return all colors found in the document.
        -- One approach to work around this could be that the LSP client and the LSP server may agree on a custom protocol that
        -- textDocument/documentColor may return partial results, and the client is expected to send more textDocument/documentColor requests.
        -- This approach is only feasible when the LSP client and the LSP server is tightly coupled.
        --
        -- In Neovim 0.12, the LSP client responsible for textDocument/documentColor is implemented in
        -- https://github.com/neovim/neovim/blob/v0.12.0/runtime/lua/vim/lsp/document_color.lua
        -- Studying the source code reveals that the LSP client sends textDocument/documentColor for the following conditions
        -- 1. When the buffer has changed lines.
        -- 2. When the buffer reloads, via :edit or :checktime
        --
        -- For the purpose of showing colors, we just need to show the colors visible in the window.
        -- So the partial results are considered as correct as long as they contain all colors visible in the window.
        -- When the window scrolls, if the LSP client can sends textDocument/documentColor, then the protocol is correct.
        --
        -- However, there is no public API to ask the LSP client to send textDocument/documentColor.
        -- Hacking on the conditions are not feasible neither, for the reasons listed below:
        -- 1. We cannot make artificial changes during scrolling to trigger condition 1.
        -- 2.1 :edit will complain when running on a buffer with changes.
        -- 2.2 :edit! will discard unsaved changes.
        -- 2.3 :checktime <bufnr> on a buffer that was not modified externally does not trigger buffer reload.
        --
        -- TL;DR: This implementation call ltree:parse() to parse the whole buffer to get all colors.
        -- This is very inefficient and only work for files with less than 1000 lines.
        if params == nil then
          callback(nil, {})
        else
          local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
          ---@param err string?
          ---@param colors { color: nvimcolors.css.color, range4: Range4 }[]?
          require("nvim-colors.treesitter").find_all_colors_inefficiently_with_callback(bufnr, function(err, colors)
            if err ~= nil then
              callback(nil, {})
            end
            if colors ~= nil then
              callback(nil, to_lsp_color_information(bufnr, colors))
            end
          end)
        end
      end
      return true, id
    end,
    ---@param method vim.lsp.protocol.Method.ClientToServer.Notification
    ---@param _params unknown
    ---@return boolean
    notify = function(method, _params)
      if method == "exit" then
        dispatchers.on_exit(0, 0)
      end
      return true
    end,
    ---@return boolean
    is_closing = function()
      return closed
    end,
    terminate = function()
      closed = true
    end,
  }
end

return M
