local M = {}

---@param dispatchers vim.lsp.rpc.Dispatchers
---@param config vim.lsp.ClientConfig
---@return vim.lsp.rpc.PublicClient
function M.new_client(dispatchers, config)
  local closed = false
  local message_id = 0

  return {
    ---@param method string
    ---@param params table?
    ---@param callback fun(err?: lsp.ResponseError, result: unknown)
    ---@param notify_reply_callback fun(message_id: integer)
    ---@return boolean, integer?
    request = function(method, params, callback, notify_reply_callback)
      message_id = message_id + 1
      local id = message_id
      if method == "initialize" then
        print("initialize", vim.inspect(params))
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
        print("shutdown", vim.inspect(params))
        callback(nil, vim.NIL)
      elseif method == "textDocument/documentColor" then
        -- In the implementation of 0.12 https://github.com/neovim/neovim/blob/v0.12.0/runtime/lua/vim/lsp/document_color.lua#L227
        -- The request asks for ALL colors in the document.
        -- If the file is large and contains millions of colors, the performance is bad.
        -- Therefore, it is not a feasible approach of using textDocument/documentColor.
        --
        -- It may be tempting to return partial results even if the client asks for ALL colors.
        -- It was observed that scrolling DOES NOT trigger a new request, so we do not have a reliable way to return partial results as the user scrolls.
        callback(nil, {})
      end
      return true, id
    end,
    ---@param method string
    ---@param params unknown
    ---@return boolean
    notify = function(method, params)
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
