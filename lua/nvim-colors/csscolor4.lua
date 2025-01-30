local M = {}

-- Ideally, we should define Angle as a tuple, but lua-language-server has this bug
-- https://github.com/LuaLS/lua-language-server/issues/2980

--- @class deg
--- @field [1] number
--- @field [2] "deg"

--- @class grad
--- @field [1] number
--- @field [2] "grad"

--- @class rad
--- @field [1] number
--- @field [2] "rad"

--- @class turn
--- @field [1] number
--- @field [2] "turn"

--- @alias angle deg | grad | rad | turn

--- @class percentage
--- @field [1] number
--- @field [2] "percentage"

--- @alias range_0_1 number
--- @alias range_0_255 number

--- @class rgb
--- @field [1] "rgb"
--- @field [2] ("none"|range_0_255)[]
--- @field [3] "none"|range_0_1|nil

--- @param grad number
--- @return number
local function grad2deg(grad)
  return grad * 360 / 400
end

--- @param rad number
--- @return number
local function rad2deg(rad)
  return rad * 360 / (2 * math.pi)
end

--- @param turn number
--- @return number
local function turn2deg(turn)
  return turn * 360
end

local to_deg = {
  ["grad"] = grad2deg,
  ["rad"] = rad2deg,
  ["turn"] = turn2deg,
}

-- https://www.w3.org/TR/css-values-4/#angles
--- @param a angle
--- @return deg
function M.to_deg(a)
  local unit = a[2]
  if unit == "deg" then
    --- @cast a deg
    return a
  end
  local f = to_deg[unit]
  if f == nil then
    error(string.format("unknown angle unit: %s", unit))
  end

  return { f(a[1]), "deg" }
end

--- @param percentage percentage
--- @param range number|nil
--- @return number
function M.percentage2number(percentage, range)
  if range == nil then
    range = 1
  end
  local n = percentage[1] / 100
  return n * range
end

--- @param value string
--- @return number|nil
local function parse_number(value)
  local s = string.find(value, "^(0[xX])")
  if s ~= nil then
    return nil
  end
  return tonumber(value)
end

--- @param value string
--- @return percentage|nil
local function parse_percentage(value)
  local s = string.find(value, "(%%)$")
  if s ~= nil then
    local number = parse_number(string.sub(value, 0, s - 1))
    if number ~= nil then
      return { number, "percentage" }
    end
  end
  return nil
end

--- @param value string
--- @return deg|nil
local function parse_deg(value)
  local s = string.find(value, "(deg)$")
  if s ~= nil then
    local number = parse_number(string.sub(value, 0, s - 1))
    if number ~= nil then
      return { number, "deg" }
    end
  end
  return nil
end

--- @param value string
--- @return grad|nil
local function parse_grad(value)
  local s = string.find(value, "(grad)$")
  if s ~= nil then
    local number = parse_number(string.sub(value, 0, s - 1))
    if number ~= nil then
      return { number, "grad" }
    end
  end
  return nil
end

--- @param value string
--- @return rad|nil
local function parse_rad(value)
  local s = string.find(value, "(rad)$")
  if s ~= nil then
    local number = parse_number(string.sub(value, 0, s - 1))
    if number ~= nil then
      return { number, "rad" }
    end
  end
  return nil
end

--- @param value string
--- @return turn|nil
local function parse_turn(value)
  local s = string.find(value, "(turn)$")
  if s ~= nil then
    local number = parse_number(string.sub(value, 0, s - 1))
    if number ~= nil then
      return { number, "turn" }
    end
  end
  return nil
end

--- @param value string
--- @return angle|nil
local function parse_angle(value)
  local deg = parse_deg(value)
  if deg ~= nil then
    return deg
  end
  -- This must come before parse_rad because rad is a suffix of grad.
  local grad = parse_grad(value)
  if grad ~= nil then
    return grad
  end
  local rad = parse_rad(value)
  if rad ~= nil then
    return rad
  end
  local turn = parse_turn(value)
  if turn ~= nil then
    return turn
  end
  return nil
end

--- @param value string
--- @return "none"|number|percentage|angle|nil
function M.parse_value(value)
  if string.lower(value) == "none" then
    return "none"
  end
  local percentage = parse_percentage(value)
  if percentage ~= nil then
    return percentage
  end
  local angle = parse_angle(value)
  if angle ~= nil then
    return angle
  end
  local n = parse_number(value)
  if n ~= nil then
    return n
  end
  return nil
end

--- @param v "none"|number|percentage|angle|nil
--- @param range number
--- @return "none"|number|nil
local function clamp_number_or_percentage(v, range)
  if v == nil then
    return nil
  end
  if v == "none" then
    return "none"
  end
  if type(v) == "number" then
    return math.min(range, math.max(0, v))
  end
  local typ = v[2]
  if typ == "percentage" then
    local p = v --[[@as percentage]]
    local n = M.percentage2number(p, range)
    return math.min(range, math.max(0, n))
  end
  return nil
end

--- @param r string
--- @param g string
--- @param b string
--- @param a string|nil
--- @return rgb|nil
function M.rgb(r, g, b, a)
  -- https://www.w3.org/TR/css-color-4/#rgb-functions
  -- It says
  --   Values outside these ranges are not invalid, but are clamped to the ranges defined here at parsed-value time.

  local r__ = clamp_number_or_percentage(M.parse_value(r), 255)
  if r__ == nil then
    return nil
  end
  local g__ = clamp_number_or_percentage(M.parse_value(g), 255)
  if g__ == nil then
    return nil
  end
  local b__ = clamp_number_or_percentage(M.parse_value(b), 255)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local a__
  if a ~= nil then
    a__ = clamp_number_or_percentage(M.parse_value(a), 1)
    if a__ == nil then
      return nil
    end
  end

  return { "rgb", { r__, g__, b__ }, a__ } --[[@as rgb]]
end

return M
