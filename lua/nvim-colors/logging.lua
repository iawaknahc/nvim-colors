--- @enum (key) LoggerLevel
local level_to_string = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}

--- @class LoggerOptions
--- @field level LoggerLevel|nil
--- @field name string|nil
local LoggerOptions = {}

local default_options = {
  level = vim.log.levels.TRACE --[[@as LoggerLevel]],
  name = "NO_NAME",
}

--- @class Logger
--- @field level LoggerLevel
--- @field name string
--- @field private filename string
--- @field private logfile file*|nil
local M = {}
M.__index = M

M.TRACE = vim.log.levels.TRACE --[[@as LoggerLevel]]
M.DEBUG = vim.log.levels.DEBUG --[[@as LoggerLevel]]
M.INFO = vim.log.levels.INFO --[[@as LoggerLevel]]
M.WARN = vim.log.levels.WARN --[[@as LoggerLevel]]
M.ERROR = vim.log.levels.ERROR --[[@as LoggerLevel]]

--- @param options LoggerOptions|nil
function M.new(options)
  options = options or {}

  --- @class Logger
  local self = setmetatable({}, M)

  self.level = options.level or default_options.level
  self.name = options.name or default_options.name

  local basename = self.name .. ".log"
  local dirname = vim.fn.stdpath("log") --[[@as string]]
  self.filename = vim.fs.joinpath(dirname, basename)

  local logfile, openerr = io.open(self.filename, "a+")
  if logfile ~= nil then
    self.logfile = logfile
  else
    vim.notify(string.format("failed to open %s: %s", self.filename, openerr), vim.log.levels.ERROR)
  end

  return self
end

--- @private
--- @param level LoggerLevel
--- @param fmt string
--- @vararg unknown
function M:_log(level, fmt, ...)
  local logfile = self.logfile
  if logfile == nil then
    return
  end

  local formatted_timestamp = os.date("%Y-%m-%dT%H:%M:%S %Z")
  local formatted_level = level_to_string[level]
  local formatted_message = string.format(fmt, ...)

  local final_message = string.format("[%s][%s] %s", formatted_timestamp, formatted_level, formatted_message)

  logfile:write(final_message, "\n")
  logfile:flush()
end

--- @param fmt string
--- @vararg unknown
function M:trace(fmt, ...)
  local this_level = vim.log.levels.TRACE --[[@as LoggerLevel]]
  if this_level >= self.level then
    self:_log(this_level, fmt, ...)
  end
end

--- @param fmt string
--- @vararg unknown
function M:debug(fmt, ...)
  local this_level = vim.log.levels.DEBUG --[[@as LoggerLevel]]
  if this_level >= self.level then
    self:_log(this_level, fmt, ...)
  end
end

--- @param fmt string
--- @vararg unknown
function M:info(fmt, ...)
  local this_level = vim.log.levels.INFO --[[@as LoggerLevel]]
  if this_level >= self.level then
    self:_log(this_level, fmt, ...)
  end
end

--- @param fmt string
--- @vararg unknown
function M:warn(fmt, ...)
  local this_level = vim.log.levels.WARN --[[@as LoggerLevel]]
  if this_level >= self.level then
    self:_log(this_level, fmt, ...)
  end
end

--- @param fmt string
--- @vararg unknown
function M:error(fmt, ...)
  local this_level = vim.log.levels.ERROR --[[@as LoggerLevel]]
  if this_level >= self.level then
    self:_log(this_level, fmt, ...)
  end
end

return M
