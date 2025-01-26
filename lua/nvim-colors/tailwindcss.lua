local css = require("nvim-colors.css")
local logging = require("nvim-colors.logging")

local logger = logging:new({ name = "nvim-colors", level = vim.log.levels.INFO })

--- @class LspPosition
--- @field line integer
--- @field character integer
local LspPosition = {}

--- @class LspRange
--- @field start LspPosition
--- @field end LspPosition
local LspRange = {}

--- @class LspColor
--- @field red number
--- @field green number
--- @field blue number
--- @field alpha number
local LspColor = {}

--- @class LspColorInformation
--- @field range LspRange
--- @field color LspColor
local LspColorInformation = {}

local METHOD = "textDocument/documentColor"

--- @param fraction number
--- @return string
local function fraction_to_percentage(fraction)
  return string.format("%f", fraction * 100) .. "%"
end

--- @param lsp_color LspColor
--- @return string
local function lsp_color_to_css(lsp_color)
  local r = fraction_to_percentage(lsp_color.red)
  local g = fraction_to_percentage(lsp_color.green)
  local b = fraction_to_percentage(lsp_color.blue)
  local a = fraction_to_percentage(lsp_color.alpha)
  return string.format("rgb(%s %s %s / %s)", r, g, b, a)
end

--- @param lsp_range LspRange
--- @return Range4
local function lsp_range_to_range4(lsp_range)
  return {
    lsp_range.start.line,
    lsp_range.start.character,
    lsp_range["end"].line,
    lsp_range["end"].character,
  }
end

--- @param result LspColorInformation[]
--- @return TailwindcssItem[]
local function convert_result(result)
  --- @type TailwindcssItem[]
  local items = {}
  for _, info in ipairs(result) do
    local css_color = lsp_color_to_css(info.color)
    local range4 = lsp_range_to_range4(info.range)
    table.insert(items, {
      css_color = css_color,
      range4 = range4,
    })
  end
  return items
end

--- @param client_id integer
--- @param bufnr integer
--- @return vim.lsp.Client?
local function get_client(client_id, bufnr)
  local client = vim.lsp.get_client_by_id(client_id)
  if client == nil then
    return nil
  end
  if client.name ~= "tailwindcss" then
    return nil
  end
  local supported = client.supports_method(METHOD, { bufnr = bufnr })
  if not supported then
    return nil
  end

  return client
end

--- @class TailwindcssRequestContext
--- @field bufnr integer
--- @field request_id integer
local TailwindcssRequestContext = {}

--- @class TailwindcssItem
--- @field css_color string
--- @field range4 Range4
local TailwindcssItem = {}

--- @param client vim.lsp.Client
--- @param bufnr integer
--- @param callback fun(ctx: TailwindcssRequestContext, err: lsp.ResponseError|nil, result: TailwindcssItem[]|nil)
--- @return integer?
local function make_request(client, bufnr, callback)
  local ok = false
  --- @type integer?
  local request_id = nil

  --- @param err lsp.ResponseError?
  --- @param result LspColorInformation[]?
  local function handler(err, result)
    if err ~= nil then
      --- @cast request_id integer
      callback({ bufnr = bufnr, request_id = request_id }, err, nil)
    elseif result ~= nil then
      --- @cast request_id integer
      callback({ bufnr = bufnr, request_id = request_id }, nil, convert_result(result))
    else
      --- @cast request_id integer
      callback({ bufnr = bufnr, request_id = request_id }, nil, {})
    end
  end

  ok, request_id = client.request(METHOD, {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
  }, handler, bufnr)
  if ok and request_id ~= nil then
    return request_id
  end
end

--- @param result ConvertCSSColorResult
--- @return string
local function get_nvim_hl_group_name(result)
  return string.format(
    "nvim_colors_tailwindcss_%s_%s",
    string.gsub(result.highlight_fg, "#", ""),
    string.gsub(result.highlight_bg, "#", "")
  )
end

--- @class (exact) NewTailwindcssHighlighterOptions
--- @field bufnr integer
--- @field ns integer
--- @field client_id integer
local NewTailwindcssHighlighterOptions = {}

--- @class TailwindcssHighlighter
--- @field private bufnr integer
--- @field private client vim.lsp.Client
--- @field private ns integer
--- @field enabled boolean
--- @field private pending_request_id integer|nil
--- @field private closed boolean
--- @field private cached_items TailwindcssItem[]
local TailwindcssHighlighter = {}
TailwindcssHighlighter.__index = TailwindcssHighlighter

--- @param options NewTailwindcssHighlighterOptions
--- @return TailwindcssHighlighter?
function TailwindcssHighlighter.new(options)
  local client = get_client(options.client_id, options.bufnr)
  if client ~= nil then
    local self = setmetatable({}, TailwindcssHighlighter)
    self.bufnr = options.bufnr
    self.client = client
    self.ns = options.ns
    self.enabled = true
    self.pending_request_id = nil
    self.closed = false
    self.cached_items = {}
    return self
  end
end

function TailwindcssHighlighter:destroy()
  self.closed = true
end

function TailwindcssHighlighter:make_request()
  if self.closed then
    return
  end

  if not self.enabled then
    return
  end

  local pending_request_id = self.pending_request_id
  if pending_request_id ~= nil then
    return
  end

  self.pending_request_id = make_request(self.client, self.bufnr, function(ctx, err, result)
    if self.closed then
      return
    end

    if not self.enabled then
      return
    end

    if ctx.request_id ~= self.pending_request_id then
      return
    end

    if err ~= nil then
      return
    end

    if result == nil then
      return
    end

    self.pending_request_id = nil
    self.cached_items = result
    vim.api.nvim__redraw({ buf = self.bufnr, valid = false })
  end)
end

--- @param winid integer
--- @param toprow integer
--- @param botrow integer
function TailwindcssHighlighter:on_win(winid, toprow, botrow)
  if not self.enabled then
    return
  end

  local fg, bg = css.get_fg_bg_from_colorscheme()

  local items = self.cached_items
  for _, item in ipairs(items) do
    local item_range = item.range4
    if item_range[1] >= toprow and item_range[3] <= botrow then
      local css_color = item.css_color
      local result = css.convert_css_color({
        color = css_color,
        fg_color = fg,
        bg_color = bg,
      })
      if result then
        local hl_group = get_nvim_hl_group_name(result)
        vim.api.nvim_set_hl(self.ns, hl_group, {
          fg = result.highlight_fg,
          bg = result.highlight_bg,
        })
        vim.api.nvim_buf_set_extmark(self.bufnr, self.ns, item_range[1], item_range[2], {
          end_row = item_range[3],
          end_col = item_range[4],
          hl_group = hl_group,
          ephemeral = true,
        })
      end
    end
  end
end

--- @type { [integer]: TailwindcssHighlighter? }
local highlighters = {}

local M = {}

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
  local augroup = vim.api.nvim_create_augroup("nvim-colors/tailwindcss", {})
  local ns = vim.api.nvim_create_namespace("nvim-colors/tailwindcss")

  vim.api.nvim_create_autocmd({
    "LspAttach",
  }, {
    callback = function(ev)
      local bufnr = ev.buf
      local highlighter = highlighters[bufnr]
      if highlighter == nil then
        local client_id = ev.data.client_id
        highlighter = TailwindcssHighlighter.new({
          bufnr = bufnr,
          ns = ns,
          client_id = client_id,
        })
        if highlighter ~= nil then
          highlighters[bufnr] = highlighter
          highlighter:make_request()
        end
      end
    end,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({ "LspDetach" }, {
    callback = function(ev)
      local bufnr = ev.buf
      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter:destroy()
        highlighters[bufnr] = nil
      end
    end,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({
    "BufWinEnter",
    "InsertLeave",
    "TextChanged",
  }, {
    callback = function(ev)
      local bufnr = ev.buf
      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter:make_request()
      end
    end,
    group = augroup,
  })

  vim.api.nvim_set_decoration_provider(ns, {
    --- @param winid integer
    --- @param bufnr integer
    --- @param toprow integer
    --- @param botrow integer
    on_win = function(_, winid, bufnr, toprow, botrow)
      vim.api.nvim_set_hl_ns_fast(ns)
      local highlighter = highlighters[bufnr]
      if highlighter ~= nil then
        highlighter:on_win(winid, toprow, botrow)
      end
    end,
  })
end

return M
