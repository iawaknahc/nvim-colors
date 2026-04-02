return {
  ---@param dispatchers vim.lsp.rpc.Dispatchers
  ---@param config vim.lsp.ClientConfig
  ---@return vim.lsp.rpc.PublicClient
  cmd = function(dispatchers, config)
    return require("nvim-colors.lsp").new_client(dispatchers, config)
  end,
  -- nil for ALL filetypes.
  filetypes = nil,
}
