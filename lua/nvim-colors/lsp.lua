local M = {}

---@param dispatchers vim.lsp.rpc.Dispatchers
---@param _config vim.lsp.ClientConfig
---@return vim.lsp.rpc.PublicClient
function M.new_client(dispatchers, _config)
  local closed = false
  local message_id = 0

  return {
    ---@param method string
    ---@param _params table?
    ---@param callback fun(err?: lsp.ResponseError, result: unknown)
    ---@param _notify_reply_callback fun(message_id: integer)
    ---@return boolean, integer?
    request = function(method, _params, callback, _notify_reply_callback)
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
        callback(nil, {})
      end
      return true, id
    end,
    ---@param method string
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
