local default_options = {
  level = vim.log.levels.TRACE,
  name = "NO_NAME",
}

local level_to_string = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}

local M = {}

function M:new(instance)
  instance = instance or {}

  instance.level = instance.level or default_options.level
  instance.name = instance.name or default_options.name

  setmetatable(instance, { __index = self })
  return instance
end

function M:log(level, fmt, ...)
  local formatted_timestamp = os.date("%Y-%m-%dT%H:%M:%S %Z")
  local formatted_level = level_to_string[level]
  local formatted_message = string.format(fmt, ...)

  local final_message =
    string.format("[%s][%s] %s", formatted_timestamp, formatted_level, formatted_message)

  local path_to_log_file = table.concat({ vim.fn.stdpath("log"), self.name .. ".log" }, "/")

  vim.uv.fs_open(path_to_log_file, "a+", tonumber("600", 8), function(err, file)
    if file and not err then
      local file_pipe = vim.uv.new_pipe(false)
      vim.uv.pipe_open(file_pipe, file)
      vim.uv.write(file_pipe, final_message .. "\n")
      vim.uv.fs_close(file)
    end
  end)
end

function M:trace(fmt, ...)
  local this_level = vim.log.levels.TRACE
  if this_level >= self.level then
    self:log(this_level, fmt, ...)
  end
end

function M:debug(fmt, ...)
  local this_level = vim.log.levels.DEBUG
  if this_level >= self.level then
    self:log(this_level, fmt, ...)
  end
end

function M:info(fmt, ...)
  local this_level = vim.log.levels.INFO
  if this_level >= self.level then
    self:log(this_level, fmt, ...)
  end
end

function M:warn(fmt, ...)
  local this_level = vim.log.levels.WARN
  if this_level >= self.level then
    self:log(this_level, fmt, ...)
  end
end

function M:error(fmt, ...)
  local this_level = vim.log.levels.ERROR
  if this_level >= self.level then
    self:log(this_level, fmt, ...)
  end
end

return M
