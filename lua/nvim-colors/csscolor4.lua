local multiply_matrices = require("nvim-colors.multiply_matrices")

local M = {}

-- Ideally, we should define Angle as a tuple, but lua-language-server has this bug
-- https://github.com/LuaLS/lua-language-server/issues/2980

--- @class (exact) deg
--- @field [1] number
--- @field [2] "deg"

--- @class (exact) grad
--- @field [1] number
--- @field [2] "grad"

--- @class (exact) rad
--- @field [1] number
--- @field [2] "rad"

--- @class (exact) turn
--- @field [1] number
--- @field [2] "turn"

--- @alias angle deg | grad | rad | turn

--- @class (exact) percentage
--- @field [1] number
--- @field [2] "percentage"

--- @alias range_0_04 number
--- @alias range_0_1 number
--- @alias range_0_100 number
--- @alias range_0_125 number
--- @alias range_0_150 number
--- @alias range_0_255 number
--- @alias range_0_360 number

--- @class (exact) rgb
--- @field [1] "rgb"
--- @field [2] ("none"|range_0_255)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) hsl_coords
--- @field [1] "none"|range_0_360
--- @field [2] "none"|range_0_100
--- @field [3] "none"|range_0_100

--- @class (exact) hsl
--- @field [1] "hsl"
--- @field [2] hsl_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) hwb_coords
--- @field [1] "none"|range_0_360
--- @field [2] "none"|range_0_100
--- @field [3] "none"|range_0_100

--- @class (exact) hwb
--- @field [1] "hwb"
--- @field [2] hwb_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) lab_coords
--- @field [1] "none"|range_0_100
--- @field [2] "none"|range_0_125
--- @field [3] "none"|range_0_125

--- @class (exact) lab
--- @field [1] "lab"
--- @field [2] lab_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) lch_coords
--- @field [1] "none"|range_0_100
--- @field [2] "none"|range_0_150
--- @field [3] "none"|range_0_360

--- @class (exact) lch
--- @field [1] "lch"
--- @field [2] lch_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) oklab_coords
--- @field [1] "none"|range_0_1
--- @field [2] "none"|range_0_04
--- @field [3] "none"|range_0_04

--- @class (exact) oklab
--- @field [1] "oklab"
--- @field [2] oklab_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) oklch_coords
--- @field [1] "none"|range_0_1
--- @field [2] "none"|range_0_04
--- @field [3] "none"|range_0_360

--- @class (exact) oklch
--- @field [1] "oklch"
--- @field [2] oklch_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) srgb
--- @field [1] "srgb"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) srgb_linear
--- @field [1] "srgb-linear"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) display_p3
--- @field [1] "display-p3"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) display_p3_linear
--- @field [1] "display-p3-linear"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) a98_rgb
--- @field [1] "a98-rgb"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) a98_rgb_linear
--- @field [1] "a98-rgb-linear"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) prophoto_rgb
--- @field [1] "prophoto-rgb"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) prophoto_rgb_linear
--- @field [1] "prophoto-rgb-linear"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) rec2020
--- @field [1] "rec2020"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) rec2020_linear
--- @field [1] "rec2020-linear"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) xyz
--- @field [1] "xyz"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) xyz_d50
--- @field [1] "xyz-d50"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) xyz_d65
--- @field [1] "xyz-d65"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @alias colorspace "rgb"|"hsl"|"hwb"|"lab"|"lch"|"oklab"|"oklch"|"srgb"|"srgb-linear"|"display-p3"|"display-p3-linear"|"a98-rgb"|"a98-rgb-linear"|"prophoto-rgb"|"prophoto-rgb-linear"|"rec2020"|"rec2020-linear"|"xyz"|"xyz-d50"|"xyz-d65"

--- @alias color rgb|hsl|hwb|lab|lch|oklab|oklch|srgb|srgb_linear|display_p3|display_p3_linear|a98_rgb|a98_rgb_linear|prophoto_rgb|prophoto_rgb_linear|rec2020|rec2020_linear|xyz|xyz_d50|xyz_d65

---@class (exact) colorspace_conversion
---@field [1] colorspace
---@field [2] colorspace
---@field [3] fun(color): color

---@class (exact) CoordRange
---@field min number
---@field max number
---@field is_unbounded boolean|nil

---@class (exact) Coord
---@field range CoordRange
---@field type "angle"|"number"

---@class (exact) ColorSpace
---@field colorspace colorspace
---@field gamut_colorspace colorspace
---@field coords Coord[]
local ColorSpace = {}

---@type ColorSpace[]
M.ALL_COLORSPACES = {
  {
    colorspace = "rgb",
    gamut_colorspace = "rgb",
    coords = {
      { type = "number", range = { min = 0, max = 255 } },
      { type = "number", range = { min = 0, max = 255 } },
      { type = "number", range = { min = 0, max = 255 } },
    },
  },
  {
    colorspace = "hsl",
    gamut_colorspace = "srgb",
    coords = {
      { type = "angle", range = { min = 0, max = 360, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 100 } },
      { type = "number", range = { min = 0, max = 100 } },
    },
  },
  {
    colorspace = "hwb",
    gamut_colorspace = "srgb",
    coords = {
      { type = "angle", range = { min = 0, max = 360, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 100 } },
      { type = "number", range = { min = 0, max = 100 } },
    },
  },
  {
    colorspace = "lab",
    gamut_colorspace = "lab",
    coords = {
      { type = "number", range = { min = 0, max = 100, is_unbounded = true } },
      { type = "number", range = { min = -125, max = 125, is_unbounded = true } },
      { type = "number", range = { min = -125, max = 125, is_unbounded = true } },
    },
  },
  {
    colorspace = "lch",
    gamut_colorspace = "lab",
    coords = {
      { type = "number", range = { min = 0, max = 100, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 150, is_unbounded = true } },
      { type = "angle", range = { min = 0, max = 360, is_unbounded = true } },
    },
  },
  {
    colorspace = "oklab",
    gamut_colorspace = "oklab",
    coords = {
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = -0.4, max = 0.4, is_unbounded = true } },
      { type = "number", range = { min = -0.4, max = 0.4, is_unbounded = true } },
    },
  },
  {
    colorspace = "oklch",
    gamut_colorspace = "oklab",
    coords = {
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 0.4, is_unbounded = true } },
      { type = "angle", range = { min = 0, max = 360, is_unbounded = true } },
    },
  },
  {
    colorspace = "srgb",
    gamut_colorspace = "srgb",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "srgb-linear",
    gamut_colorspace = "srgb-linear",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "display-p3",
    gamut_colorspace = "display-p3",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "display-p3-linear",
    gamut_colorspace = "display-p3-linear",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "a98-rgb",
    gamut_colorspace = "a98-rgb",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "a98-rgb-linear",
    gamut_colorspace = "a98-rgb-linear",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "prophoto-rgb",
    gamut_colorspace = "prophoto-rgb",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "prophoto-rgb-linear",
    gamut_colorspace = "prophoto-rgb-linear",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "rec2020",
    gamut_colorspace = "rec2020",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "rec2020-linear",
    gamut_colorspace = "rec2020-linear",
    coords = {
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
      { type = "number", range = { min = 0, max = 1 } },
    },
  },
  {
    colorspace = "xyz",
    gamut_colorspace = "xyz",
    coords = {
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
    },
  },
  {
    colorspace = "xyz-d50",
    gamut_colorspace = "xyz-d50",
    coords = {
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
    },
  },
  {
    colorspace = "xyz-d65",
    gamut_colorspace = "xyz-d65",
    coords = {
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
      { type = "number", range = { min = 0, max = 1, is_unbounded = true } },
    },
  },
}

--- @param grad number
--- @return number
local function grad_to_deg(grad)
  return grad * 360 / 400
end

--- @param rad number
--- @return number
local function rad_to_deg(rad)
  return rad * 360 / (2 * math.pi)
end

--- @param turn number
--- @return number
local function turn_to_deg(turn)
  return turn * 360
end

local to_deg = {
  ["grad"] = grad_to_deg,
  ["rad"] = rad_to_deg,
  ["turn"] = turn_to_deg,
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
function M.percentage_to_number(percentage, range)
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
    local n = M.percentage_to_number(p, range)
    return math.min(range, math.max(0, n))
  end
  return nil
end

--- @param v "none"|number|percentage|angle|nil
--- @param range number
--- @return "none"|number|nil
local function keep_number_or_percentage(v, range)
  if v == nil then
    return nil
  end
  if v == "none" then
    return "none"
  end
  if type(v) == "number" then
    return v
  end
  local typ = v[2]
  if typ == "percentage" then
    local p = v --[[@as percentage]]
    local n = M.percentage_to_number(p, range)
    return n
  end
  return nil
end

--- @param v "none"|number|nil
--- @return "none"|number|nil
local function clamp_negative_to_zero(v)
  if v == nil then
    return nil
  end
  if v == "none" then
    return "none"
  end
  if type(v) == "number" then
    if v < 0 then
      return 0
    end
    return v
  end
  return nil
end

--- @param v "none"|number|percentage|angle|nil
--- @return "none"|number|nil
local function normalize_hue(v)
  if v == nil then
    return nil
  end
  if v == "none" then
    return "none"
  end
  if type(v) == "number" then
    return v % 360
  end
  local typ = v[2]
  if typ == "deg" or typ == "grad" or typ == "rad" or typ == "turn" then
    local angle = v --[[@as angle]]
    local deg = M.to_deg(angle)
    return deg[1] % 360
  end
  return nil
end

--- @param v "none"|number|percentage|angle|nil
--- @return "none"|number|nil
local function normalize_hsl_saturation(v)
  if v == nil then
    return nil
  end
  if v == "none" then
    return "none"
  end
  if type(v) == "number" then
    -- https://www.w3.org/TR/css-color-4/#the-hsl-notation
    -- It says
    --   For historical reasons, if the saturation is less than 0% it is clamped to 0% at parsed-value time,
    --   before being converted to an sRGB color.
    return math.max(0, v)
  end
  local typ = v[2]
  if typ == "percentage" then
    local p = v --[[@as percentage]]
    local n = M.percentage_to_number(p, 100)
    return math.max(0, n)
  end
  return nil
end

--- @param v string
--- @return "none"|number|nil
local function parse_alpha(v)
  -- https://www.w3.org/TR/css-color-4/#alpha-syntax
  -- It says
  --   	Values outside the range [0,1] are not invalid, but are clamped to that range at parsed-value time.
  return clamp_number_or_percentage(M.parse_value(v), 1)
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return rgb|nil
function M.rgb(r, g, b, alpha)
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
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "rgb", { r__, g__, b__ }, alpha__ } --[[@as rgb]]
end

--- @param h string
--- @param s string
--- @param l string
--- @param alpha string|nil
--- @return hsl|nil
function M.hsl(h, s, l, alpha)
  local h__ = normalize_hue(M.parse_value(h))
  if h__ == nil then
    return nil
  end

  local s__ = normalize_hsl_saturation(M.parse_value(s))
  if s__ == nil then
    return nil
  end

  local l__ = keep_number_or_percentage(M.parse_value(l), 100)
  if l__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "hsl", { h__, s__, l__ }, alpha__ } --[[@as hsl]]
end

--- @param h string
--- @param w string
--- @param b string
--- @param alpha string|nil
--- @return hwb|nil
function M.hwb(h, w, b, alpha)
  local h__ = normalize_hue(M.parse_value(h))
  if h__ == nil then
    return nil
  end

  local w__ = keep_number_or_percentage(M.parse_value(w), 100)
  if w__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 100)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "hwb", { h__, w__, b__ }, alpha__ } --[[@as hwb]]
end

--- @param L string
--- @param a string
--- @param b string
--- @param alpha string|nil
--- @return lab|nil
function M.lab(L, a, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#specifying-lab-lch
  -- It says
  --   Values less than 0% or 0 must be clamped to 0% at parsed-value time; values greater than 100% or 100 are clamped to 100% at parsed-value time.
  local L__ = clamp_number_or_percentage(M.parse_value(L), 100)
  if L__ == nil then
    return nil
  end

  local a__ = keep_number_or_percentage(M.parse_value(a), 125)
  if a__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 125)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "lab", { L__, a__, b__ }, alpha__ } --[[@as lab]]
end

--- @param L string
--- @param C string
--- @param h string
--- @param alpha string|nil
--- @return lch|nil
function M.lch(L, C, h, alpha)
  -- https://www.w3.org/TR/css-color-4/#specifying-lch-lch
  -- It says
  --   interpreted identically to the Lightness argument of lab().
  local L__ = clamp_number_or_percentage(M.parse_value(L), 100)
  if L__ == nil then
    return nil
  end

  -- It says
  --   If the provided value is negative, it is clamped to 0 at parsed-value time.
  local C__ = clamp_negative_to_zero(keep_number_or_percentage(M.parse_value(C), 150))
  if C__ == nil then
    return nil
  end

  local h__ = normalize_hue(M.parse_value(h))
  if h__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "lch", { L__, C__, h__ }, alpha__ } --[[@as lch]]
end

--- @param L string
--- @param a string
--- @param b string
--- @param alpha string|nil
--- @return oklab|nil
function M.oklab(L, a, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#specifying-oklab-oklch
  -- It says
  --   Values less than 0% or 0.0 must be clamped to 0% at parsed-value time; values greater than 100% or 1.0 are clamped to 100% at parsed-value time.
  local L__ = clamp_number_or_percentage(M.parse_value(L), 1)
  if L__ == nil then
    return nil
  end

  local a__ = keep_number_or_percentage(M.parse_value(a), 0.4)
  if a__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 0.4)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "oklab", { L__, a__, b__ }, alpha__ } --[[@as oklab]]
end

--- @param L string
--- @param C string
--- @param h string
--- @param alpha string|nil
--- @return oklch|nil
function M.oklch(L, C, h, alpha)
  -- https://www.w3.org/TR/css-color-4/#specifying-oklch-oklch
  -- It says
  --   interpreted identically to the Lightness argument of oklab().
  local L__ = clamp_number_or_percentage(M.parse_value(L), 1)
  if L__ == nil then
    return nil
  end

  -- It says
  --   If the provided value is negative, it is clamped to 0 at parsed-value time.
  local C__ = clamp_negative_to_zero(keep_number_or_percentage(M.parse_value(C), 0.4))
  if C__ == nil then
    return nil
  end

  local h__ = normalize_hue(M.parse_value(h))
  if h__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "oklch", { L__, C__, h__ }, alpha__ } --[[@as oklch]]
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return srgb|nil
function M.srgb(r, g, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#color-function
  -- It says
  --   An out of gamut color has component values less than 0 or 0%, or greater than 1 or 100%.
  --   These are not invalid, and are retained for intermediate computations

  local r__ = keep_number_or_percentage(M.parse_value(r), 1)
  if r__ == nil then
    return nil
  end

  local g__ = keep_number_or_percentage(M.parse_value(g), 1)
  if g__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 1)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "srgb", { r__, g__, b__ }, alpha__ } --[[@as srgb]]
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return srgb_linear|nil
function M.srgb_linear(r, g, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#color-function
  -- It says
  --   An out of gamut color has component values less than 0 or 0%, or greater than 1 or 100%.
  --   These are not invalid, and are retained for intermediate computations

  local r__ = keep_number_or_percentage(M.parse_value(r), 1)
  if r__ == nil then
    return nil
  end

  local g__ = keep_number_or_percentage(M.parse_value(g), 1)
  if g__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 1)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "srgb-linear", { r__, g__, b__ }, alpha__ } --[[@as srgb_linear]]
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return display_p3|nil
function M.display_p3(r, g, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#color-function
  -- It says
  --   An out of gamut color has component values less than 0 or 0%, or greater than 1 or 100%.
  --   These are not invalid, and are retained for intermediate computations

  local r__ = keep_number_or_percentage(M.parse_value(r), 1)
  if r__ == nil then
    return nil
  end

  local g__ = keep_number_or_percentage(M.parse_value(g), 1)
  if g__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 1)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "display-p3", { r__, g__, b__ }, alpha__ } --[[@as display_p3]]
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return a98_rgb|nil
function M.a98_rgb(r, g, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#color-function
  -- It says
  --   An out of gamut color has component values less than 0 or 0%, or greater than 1 or 100%.
  --   These are not invalid, and are retained for intermediate computations

  local r__ = keep_number_or_percentage(M.parse_value(r), 1)
  if r__ == nil then
    return nil
  end

  local g__ = keep_number_or_percentage(M.parse_value(g), 1)
  if g__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 1)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "a98-rgb", { r__, g__, b__ }, alpha__ } --[[@as a98_rgb]]
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return prophoto_rgb|nil
function M.prophoto_rgb(r, g, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#color-function
  -- It says
  --   An out of gamut color has component values less than 0 or 0%, or greater than 1 or 100%.
  --   These are not invalid, and are retained for intermediate computations

  local r__ = keep_number_or_percentage(M.parse_value(r), 1)
  if r__ == nil then
    return nil
  end

  local g__ = keep_number_or_percentage(M.parse_value(g), 1)
  if g__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 1)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "prophoto-rgb", { r__, g__, b__ }, alpha__ } --[[@as prophoto_rgb]]
end

--- @param r string
--- @param g string
--- @param b string
--- @param alpha string|nil
--- @return rec2020|nil
function M.rec2020(r, g, b, alpha)
  -- https://www.w3.org/TR/css-color-4/#color-function
  -- It says
  --   An out of gamut color has component values less than 0 or 0%, or greater than 1 or 100%.
  --   These are not invalid, and are retained for intermediate computations

  local r__ = keep_number_or_percentage(M.parse_value(r), 1)
  if r__ == nil then
    return nil
  end

  local g__ = keep_number_or_percentage(M.parse_value(g), 1)
  if g__ == nil then
    return nil
  end

  local b__ = keep_number_or_percentage(M.parse_value(b), 1)
  if b__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "rec2020", { r__, g__, b__ }, alpha__ } --[[@as rec2020]]
end

--- @param x string
--- @param y string
--- @param z string
--- @param alpha string|nil
--- @return xyz|nil
function M.xyz(x, y, z, alpha)
  -- https://www.w3.org/TR/css-color-4/#predefined-xyz
  -- It says
  --   Values greater than 1.0/100% are allowed and must not be clamped;
  --   they represent colors brighter than diffuse white.
  --   Values less than 0/0% are uncommon, but can occur as a result of chromatic adaptation, and likewise must not be clamped.

  local x__ = keep_number_or_percentage(M.parse_value(x), 1)
  if x__ == nil then
    return nil
  end

  local y__ = keep_number_or_percentage(M.parse_value(y), 1)
  if y__ == nil then
    return nil
  end

  local z__ = keep_number_or_percentage(M.parse_value(z), 1)
  if z__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "xyz", { x__, y__, z__ }, alpha__ } --[[@as xyz]]
end

--- @param x string
--- @param y string
--- @param z string
--- @param alpha string|nil
--- @return xyz_d50|nil
function M.xyz_d50(x, y, z, alpha)
  -- https://www.w3.org/TR/css-color-4/#predefined-xyz
  -- It says
  --   Values greater than 1.0/100% are allowed and must not be clamped;
  --   they represent colors brighter than diffuse white.
  --   Values less than 0/0% are uncommon, but can occur as a result of chromatic adaptation, and likewise must not be clamped.

  local x__ = keep_number_or_percentage(M.parse_value(x), 1)
  if x__ == nil then
    return nil
  end

  local y__ = keep_number_or_percentage(M.parse_value(y), 1)
  if y__ == nil then
    return nil
  end

  local z__ = keep_number_or_percentage(M.parse_value(z), 1)
  if z__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "xyz-d50", { x__, y__, z__ }, alpha__ } --[[@as xyz_d50]]
end

--- @param x string
--- @param y string
--- @param z string
--- @param alpha string|nil
--- @return xyz_d65|nil
function M.xyz_d65(x, y, z, alpha)
  -- https://www.w3.org/TR/css-color-4/#predefined-xyz
  -- It says
  --   Values greater than 1.0/100% are allowed and must not be clamped;
  --   they represent colors brighter than diffuse white.
  --   Values less than 0/0% are uncommon, but can occur as a result of chromatic adaptation, and likewise must not be clamped.

  local x__ = keep_number_or_percentage(M.parse_value(x), 1)
  if x__ == nil then
    return nil
  end

  local y__ = keep_number_or_percentage(M.parse_value(y), 1)
  if y__ == nil then
    return nil
  end

  local z__ = keep_number_or_percentage(M.parse_value(z), 1)
  if z__ == nil then
    return nil
  end

  --- @type "none"|number|nil
  local alpha__
  if alpha ~= nil then
    alpha__ = parse_alpha(alpha)
    if alpha__ == nil then
      return nil
    end
  end

  return { "xyz-d65", { x__, y__, z__ }, alpha__ } --[[@as xyz_d65]]
end

--- @param v number
--- @return number
local function get_sign(v)
  if v < 0 then
    return -1
  end
  return 1
end

--- @param color rgb
--- @return srgb
function M.rgb_to_srgb(color)
  local coords = {}
  for idx, c in ipairs(color[2]) do
    if type(c) == "number" then
      coords[idx] = c / 255
    else
      coords[idx] = c
    end
  end
  return { "srgb", coords, color[3] } --[[@as srgb]]
end

--- @param color srgb
--- @return rgb
function M.srgb_to_rgb(color)
  local coords = {}
  for idx, c in ipairs(color[2]) do
    if type(c) == "number" then
      coords[idx] = c * 255
    else
      coords[idx] = c
    end
  end
  return { "rgb", coords, color[3] } --[[@as rgb]]
end

--- @param v "none"|number
--- @return number
local function none_to_zero(v)
  if type(v) == "number" then
    return v
  end
  return 0
end

--- @param color hsl
--- @return srgb
function M.hsl_to_srgb(color)
  -- https://www.w3.org/TR/css-color-4/#hsl-to-rgb
  local hue = none_to_zero(color[2][1]) % 360
  local sat = none_to_zero(color[2][2]) / 100
  local light = none_to_zero(color[2][3]) / 100

  --- @param n 0|4|8
  --- @return number
  local function f(n)
    local k = (n + hue / 30) % 12
    local a = sat * math.min(light, 1 - light)
    return light - a * math.max(-1, math.min(k - 3, 9 - k, 1))
  end

  local coords = { f(0), f(8), f(4) }
  return { "srgb", coords, color[3] } --[[@as srgb]]
end

--- @param color srgb
--- @return hsl
function M.srgb_to_hsl(color)
  -- https://www.w3.org/TR/css-color-4/#rgb-to-hsl
  local red = none_to_zero(color[2][1])
  local green = none_to_zero(color[2][2])
  local blue = none_to_zero(color[2][3])

  local max = math.max(red, green, blue)
  local min = math.min(red, green, blue)

  --- @type "none"|number
  local hue = "none"
  local sat = 0
  local light = (min + max) / 2

  local d = max - min

  if d ~= 0 then
    if light == 0 or light == 1 then
      sat = 0
    else
      sat = (max - light) / math.min(light, 1 - light)
    end

    if red == max then
      local offset = 0
      if green < blue then
        offset = 6
      end
      hue = (green - blue) / d + offset
    elseif green == max then
      hue = (blue - red) / d + 2
    elseif blue == max then
      hue = (red - green) / d + 4
    end

    hue = hue * 60
  end

  if sat < 0 then
    if type(hue) == "number" then
      hue = hue + 180
    end
    sat = math.abs(sat)
  end

  if type(hue) == "number" then
    if hue >= 360 then
      hue = hue - 360
    end
  end

  local coords = { hue, sat * 100, light * 100 }
  return { "hsl", coords, color[3] } --[[@as hsl]]
end

--- @param in_coords ("none"|number)[]
--- @return ("none"|number)[]
local function lin_sRGB(in_coords)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_sRGB
  local out_coords = {}
  for idx, c in ipairs(in_coords) do
    if type(c) == "number" then
      local sign = get_sign(c)
      local abs = math.abs(c)
      --- @type number
      local cl
      if abs <= 0.04045 then
        cl = c / 12.92
      else
        cl = sign * math.pow((abs + 0.055) / 1.055, 2.4)
      end
      out_coords[idx] = cl
    else
      out_coords[idx] = c
    end
  end
  return out_coords
end

--- @param in_coords ("none"|number)[]
--- @return ("none"|number)[]
local function gam_sRGB(in_coords)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- gam_sRGB
  local out_coords = {}
  for idx, cl in ipairs(in_coords) do
    if type(cl) == "number" then
      local sign = get_sign(cl)
      local abs = math.abs(cl)
      --- @type number
      local c
      if abs > 0.0031308 then
        c = sign * (1.055 * math.pow(abs, 1 / 2.4) - 0.055)
      else
        c = 12.92 * cl
      end
      out_coords[idx] = c
    else
      out_coords[idx] = cl
    end
  end
  return out_coords
end

--- @param color srgb
--- @return srgb_linear
function M.srgb_to_srgb_linear(color)
  local coords = lin_sRGB(color[2])
  return { "srgb-linear", coords, color[3] } --[[@as srgb_linear]]
end

--- @param color srgb_linear
--- @return srgb
function M.srgb_linear_to_srgb(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- gam_sRGB
  local coords = gam_sRGB(color[2])
  return { "srgb", coords, color[3] } --[[@as srgb]]
end

--- @param color display_p3
--- @return display_p3_linear
function M.display_p3_to_display_p3_linear(color)
  local coords = lin_sRGB(color[2])
  return { "display-p3-linear", coords, color[3] } --[[@as display_p3_linear]]
end

--- @param color display_p3_linear
--- @return display_p3
function M.display_p3_linear_to_display_p3(color)
  local coords = gam_sRGB(color[2])
  return { "display-p3", coords, color[3] } --[[@as display_p3]]
end

--- @param color hwb
--- @return srgb
function M.hwb_to_srgb(color)
  -- https://www.w3.org/TR/css-color-4/#hwb-to-rgb
  local hue = none_to_zero(color[2][1]) % 360
  local white = none_to_zero(color[2][2]) / 100
  local black = none_to_zero(color[2][3]) / 100

  local coords = {}
  if white + black >= 1 then
    local gray = white / (white + black)
    coords = { gray, gray, gray }
  else
    local srgb_coords = M.hsl_to_srgb({ "hsl", { hue, 100, 50 } })[2]
    for idx, coord in ipairs(srgb_coords) do
      if type(coord) == "number" then
        coord = coord * (1 - white - black)
        coord = coord + white
        coords[idx] = coord
      else
        coords[idx] = coord
      end
    end
  end

  return { "srgb", coords, color[3] }
end

--- @param color srgb
--- @return hwb
function M.srgb_to_hwb(color)
  -- https://www.w3.org/TR/css-color-4/#rgb-to-hwb
  local red = none_to_zero(color[2][1])
  local green = none_to_zero(color[2][2])
  local blue = none_to_zero(color[2][3])
  local hsl_coords = M.srgb_to_hsl(color)[2]
  local white = math.min(red, green, blue)
  local black = 1 - math.max(red, green, blue)
  local coords = { hsl_coords[1], white * 100, black * 100 }
  return { "hwb", coords, color[3] }
end

--- @param color lab
--- @return lch
function M.lab_to_lch(color)
  local a = none_to_zero(color[2][2])
  local b = none_to_zero(color[2][3])

  local hue = math.atan2(b, a) * 180 / math.pi
  if hue < 0 then
    hue = hue + 360
  end

  local C = math.sqrt(math.pow(a, 2) + math.pow(b, 2))
  local coords = { color[2][1], C, hue }
  return { "lch", coords, color[3] }
end

--- @param color lch
--- @return lab
function M.lch_to_lab(color)
  local C = none_to_zero(color[2][2])
  local hue = none_to_zero(color[2][3])

  local a = C * math.cos(hue * math.pi / 180)
  local b = C * math.sin(hue * math.pi / 180)
  local coords = { color[2][1], a, b }
  return { "lab", coords, color[3] }
end

--- @param color oklab
--- @return oklch
function M.oklab_to_oklch(color)
  local a = none_to_zero(color[2][2])
  local b = none_to_zero(color[2][3])

  local hue = math.atan2(b, a) * 180 / math.pi
  if hue < 0 then
    hue = hue + 360
  end

  local C = math.sqrt(math.pow(a, 2) + math.pow(b, 2))
  local coords = { color[2][1], C, hue }
  return { "oklch", coords, color[3] }
end

--- @param color oklch
--- @return oklab
function M.oklch_to_oklab(color)
  local C = none_to_zero(color[2][2])
  local hue = none_to_zero(color[2][3])

  local a = C * math.cos(hue * math.pi / 180)
  local b = C * math.sin(hue * math.pi / 180)
  local coords = { color[2][1], a, b }
  return { "oklab", coords, color[3] }
end

--- @param color prophoto_rgb
--- @return prophoto_rgb_linear
function M.prophoto_rgb_to_prophoto_rgb_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_ProPhoto
  local Et2 = 16 / 512
  local coords = {}
  for idx, val in ipairs(color[2]) do
    if type(val) == "number" then
      local sign = get_sign(val)
      local abs = math.abs(val)
      if abs <= Et2 then
        coords[idx] = val / 16
      else
        coords[idx] = sign * math.pow(abs, 1.8)
      end
    else
      coords[idx] = val
    end
  end
  return { "prophoto-rgb-linear", coords, color[3] } --[[@as prophoto_rgb_linear]]
end

--- @param color prophoto_rgb_linear
--- @return prophoto_rgb
function M.prophoto_rgb_linear_to_prophoto_rgb(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- gam_ProPhoto
  local Et = 1 / 512
  local coords = {}
  for idx, val in pairs(color[2]) do
    if type(val) == "number" then
      local sign = get_sign(val)
      local abs = math.abs(val)
      if abs >= Et then
        coords[idx] = sign * math.pow(abs, 1 / 1.8)
      else
        coords[idx] = 16 * val
      end
    else
      coords[idx] = val
    end
  end
  return { "prophoto-rgb", coords, color[3] } --[[@as prophoto_rgb]]
end

--- @param color a98_rgb
--- @return a98_rgb_linear
function M.a98_rgb_to_a98_rgb_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_a98rgb
  local coords = {}
  for idx, val in ipairs(color[2]) do
    if type(val) == "number" then
      local sign = get_sign(val)
      local abs = math.abs(val)
      coords[idx] = sign * math.pow(abs, 563 / 256)
    else
      coords[idx] = val
    end
  end
  return { "a98-rgb-linear", coords, color[3] } --[[@as a98_rgb_linear]]
end

--- @param color a98_rgb_linear
--- @return a98_rgb
function M.a98_rgb_linear_to_a98_rgb(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- gam_a98rgb
  local coords = {}
  for idx, val in ipairs(color[2]) do
    if type(val) == "number" then
      local sign = get_sign(val)
      local abs = math.abs(val)
      coords[idx] = sign * math.pow(abs, 256 / 563)
    else
      coords[idx] = val
    end
  end
  return { "a98-rgb", coords, color[3] } --[[@as a98_rgb]]
end

--- @param color rec2020
--- @return rec2020_linear
function M.rec2020_to_rec2020_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_2020
  local alpha = 1.09929682680944
  local beta = 0.018053968510807
  local coords = {}
  for idx, val in ipairs(color[2]) do
    if type(val) == "number" then
      local sign = get_sign(val)
      local abs = math.abs(val)
      if abs < beta * 4.5 then
        coords[idx] = val / 4.5
      else
        coords[idx] = sign * math.pow((abs + alpha - 1) / alpha, 1 / 0.45)
      end
    else
      coords[idx] = val
    end
  end
  return { "rec2020-linear", coords, color[3] } --[[@as rec2020_linear]]
end

--- @param color rec2020_linear
--- @return rec2020
function M.rec2020_linear_to_rec2020(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- gam_2020
  local alpha = 1.09929682680944
  local beta = 0.018053968510807
  local coords = {}
  for idx, val in ipairs(color[2]) do
    if type(val) == "number" then
      local sign = get_sign(val)
      local abs = math.abs(val)
      if abs > beta then
        coords[idx] = sign * (alpha * math.pow(abs, 0.45) - (alpha - 1))
      else
        coords[idx] = 4.5 * val
      end
    else
      coords[idx] = val
    end
  end
  return { "rec2020", coords, color[3] } --[[@as rec2020]]
end

--- @param color srgb_linear
--- @return xyz_d65
function M.srgb_linear_to_xyz_d65(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_sRGB_to_XYZ
  local M_matrix = {
    { 506752 / 1228815, 87881 / 245763, 12673 / 70218 },
    { 87098 / 409605, 175762 / 245763, 12673 / 175545 },
    { 7918 / 409605, 87881 / 737289, 1001167 / 1053270 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d65", xyz_coords, color[3] } --[[@as xyz_d65]]
end

--- @param color xyz_d65
--- @return srgb_linear
function M.xyz_d65_to_srgb_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_lin_sRGB
  local M_matrix = {
    { 12831 / 3959, -329 / 214, -1974 / 3959 },
    { -851781 / 878810, 1648619 / 878810, 36519 / 878810 },
    { 705 / 12673, -2585 / 12673, 705 / 667 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local srgb_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]

  return { "srgb-linear", srgb_coords, color[3] } --[[@as srgb_linear]]
end

--- @param color xyz_d65
--- @return display_p3_linear
function M.xyz_d65_to_display_p3_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_lin_P3
  local M_matrix = {
    { 446124 / 178915, -333277 / 357830, -72051 / 178915 },
    { -14852 / 17905, 63121 / 35810, 423 / 17905 },
    { 11844 / 330415, -50337 / 660830, 316169 / 330415 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local p3_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "display-p3-linear", p3_coords, color[3] } --[[@as display_p3_linear]]
end

--- @param color display_p3_linear
--- @return xyz_d65
function M.display_p3_linear_to_xyz_d65(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_P3_to_XYZ
  local M_matrix = {
    { 608311 / 1250200, 189793 / 714400, 198249 / 1000160 },
    { 35783 / 156275, 247089 / 357200, 198249 / 2500400 },
    { 0 / 1, 32229 / 714400, 5220557 / 5000800 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d65", xyz_coords, color[3] } --[[@as xyz_d65]]
end

--- @param color xyz_d65
--- @return a98_rgb_linear
function M.xyz_d65_to_a98_rgb_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_lin_a98rgb
  local M_matrix = {
    { 1829569 / 896150, -506331 / 896150, -308931 / 896150 },
    { -851781 / 878810, 1648619 / 878810, 36519 / 878810 },
    { 16779 / 1248040, -147721 / 1248040, 1266979 / 1248040 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local a98_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "a98-rgb-linear", a98_coords, color[3] } --[[@as a98_rgb_linear]]
end

--- @param color a98_rgb_linear
--- @return xyz_d65
function M.a98_rgb_linear_to_xyz_d65(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_a98rgb_to_XYZ
  local M_matrix = {
    { 573536 / 994567, 263643 / 1420810, 187206 / 994567 },
    { 591459 / 1989134, 6239551 / 9945670, 374412 / 4972835 },
    { 53769 / 1989134, 351524 / 4972835, 4929758 / 4972835 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d65", xyz_coords, color[3] } --[[@as xyz_d65]]
end

--- @param color xyz_d65
--- @return rec2020_linear
function M.xyz_d65_to_rec2020_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_lin_2020
  local M_matrix = {
    { 30757411 / 17917100, -6372589 / 17917100, -4539589 / 17917100 },
    { -19765991 / 29648200, 47925759 / 29648200, 467509 / 29648200 },
    { 792561 / 44930125, -1921689 / 44930125, 42328811 / 44930125 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local rec2020_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "rec2020-linear", rec2020_coords, color[3] } --[[@as rec2020_linear]]
end

--- @param color rec2020_linear
--- @return xyz_d65
function M.rec2020_linear_to_xyz_d65(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_2020_to_XYZ
  local M_matrix = {
    { 63426534 / 99577255, 20160776 / 139408157, 47086771 / 278816314 },
    { 26158966 / 99577255, 472592308 / 697040785, 8267143 / 139408157 },
    { 0 / 1, 19567812 / 697040785, 295819943 / 278816314 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d65", xyz_coords, color[3] } --[[@as xyz_d65]]
end

--- @param color xyz_d65
--- @return oklab
function M.xyz_d65_to_oklab(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_OKLab
  local XYZtoLMS = {
    { 0.819022437996703, 0.3619062600528904, -0.1288737815209879 },
    { 0.0329836539323885, 0.9292868615863434, 0.0361446663506424 },
    { 0.0481771893596242, 0.2642395317527308, 0.6335478284694309 },
  }
  local LMStoOKLab = {
    { 0.210454268309314, 0.7936177747023054, -0.0040720430116193 },
    { 1.9779985324311684, -2.4285922420485799, 0.450593709617411 },
    { 0.0259040424655478, 0.7827717124575296, -0.8086757549230774 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local LMS = multiply_matrices(XYZtoLMS, coords) --[[@as number[] ]]

  -- Apply cube root to LMS values
  local LMS_cbrt = {}
  for idx, val in ipairs(LMS) do
    if val >= 0 then
      LMS_cbrt[idx] = math.pow(val, 1 / 3)
    else
      LMS_cbrt[idx] = -math.pow(-val, 1 / 3)
    end
  end

  local oklab_coords = multiply_matrices(LMStoOKLab, LMS_cbrt) --[[@as number[] ]]
  return { "oklab", oklab_coords, color[3] } --[[@as oklab]]
end

--- @param color oklab
--- @return xyz_d65
function M.oklab_to_xyz_d65(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- OKLab_to_XYZ
  local LMStoXYZ = {
    { 1.2268798758459243, -0.5578149944602171, 0.2813910456659647 },
    { -0.0405757452148008, 1.112286803280317, -0.0717110580655164 },
    { -0.0763729366746601, -0.4214933324022432, 1.5869240198367816 },
  }
  local OKLabtoLMS = {
    { 1.0, 0.3963377773761749, 0.2158037573099136 },
    { 1.0, -0.1055613458156586, -0.0638541728258133 },
    { 1.0, -0.0894841775298119, -1.2914855480194092 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local LMSnl = multiply_matrices(OKLabtoLMS, coords) --[[@as number[] ]]

  -- Apply cube to LMS values
  local LMS_cubed = {}
  for idx, val in ipairs(LMSnl) do
    LMS_cubed[idx] = val * val * val
  end

  local xyz_coords = multiply_matrices(LMStoXYZ, LMS_cubed) --[[@as number[] ]]
  return { "xyz-d65", xyz_coords, color[3] } --[[@as xyz_d65]]
end

--- @param color xyz_d50
--- @return prophoto_rgb_linear
function M.xyz_d50_to_prophoto_rgb_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_lin_ProPhoto
  local M_matrix = {
    { 1.3457868816471583, -0.25557208737979464, -0.05110186497554526 },
    { -0.5446307051249019, 1.5082477428451468, 0.02052744743642139 },
    { 0.0, 0.0, 1.2119675456389452 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local prophoto_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "prophoto-rgb-linear", prophoto_coords, color[3] } --[[@as prophoto_rgb_linear]]
end

--- @param color prophoto_rgb_linear
--- @return xyz_d50
function M.prophoto_rgb_linear_to_xyz_d50(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_ProPhoto_to_XYZ
  local M_matrix = {
    { 0.7977666449006423, 0.13518129740053308, 0.0313477341283922 },
    { 0.2880748288194013, 0.711835234241873, 0.00008993693872564 },
    { 0.0, 0.0, 0.8251046025104602 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d50", xyz_coords, color[3] } --[[@as xyz_d50]]
end

--- @param color xyz_d50
--- @return lab
function M.xyz_d50_to_lab(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- XYZ_to_Lab
  local epsilon = 216 / 24389 -- 6^3/29^3
  local kappa = 24389 / 27 -- 29^3/3^3

  local D50 = { 0.3457 / 0.3585, 1.0, (1.0 - 0.3457 - 0.3585) / 0.3585 }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz = {}
  for i = 1, 3 do
    xyz[i] = coords[i] / D50[i]
  end

  local f = {}
  for i = 1, 3 do
    if xyz[i] > epsilon then
      f[i] = math.pow(xyz[i], 1 / 3) -- cube root
    else
      f[i] = (kappa * xyz[i] + 16) / 116
    end
  end

  local lab_coords = {
    116 * f[2] - 16, -- L
    500 * (f[1] - f[2]), -- a
    200 * (f[2] - f[3]), -- b
  }

  return { "lab", lab_coords, color[3] } --[[@as lab]]
end

--- @param color lab
--- @return xyz_d50
function M.lab_to_xyz_d50(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- Lab_to_XYZ
  local kappa = 24389 / 27 -- 29^3/3^3
  local epsilon = 216 / 24389 -- 6^3/29^3

  local D50 = { 0.3457 / 0.3585, 1.0, (1.0 - 0.3457 - 0.3585) / 0.3585 }

  ---@type number[]
  local lab_coords = {}
  for idx, c in ipairs(color[2]) do
    lab_coords[idx] = none_to_zero(c)
  end

  local f = {}

  f[2] = (lab_coords[1] + 16) / 116
  f[1] = lab_coords[2] / 500 + f[2]
  f[3] = f[2] - lab_coords[3] / 200

  local xyz = {}
  xyz[1] = math.pow(f[1], 3) > epsilon and math.pow(f[1], 3) or (116 * f[1] - 16) / kappa
  xyz[2] = lab_coords[1] > kappa * epsilon and math.pow((lab_coords[1] + 16) / 116, 3) or lab_coords[1] / kappa
  xyz[3] = math.pow(f[3], 3) > epsilon and math.pow(f[3], 3) or (116 * f[3] - 16) / kappa

  local xyz_coords = {}
  for i = 1, 3 do
    xyz_coords[i] = xyz[i] * D50[i]
  end

  return { "xyz-d50", xyz_coords, color[3] } --[[@as xyz_d50]]
end

--- @param color xyz_d65
--- @return xyz_d50
function M.xyz_d65_to_xyz_d50(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- D65_to_D50
  local M_matrix = {
    { 1.0479297925449969, 0.022946870601609652, -0.05019226628920524 },
    { 0.02962780877005599, 0.9904344267538799, -0.017073799063418826 },
    { -0.009243040646204504, 0.015055191490298152, 0.7518742814281371 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_d50_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d50", xyz_d50_coords, color[3] } --[[@as xyz_d50]]
end

--- @param color xyz_d50
--- @return xyz_d65
function M.xyz_d50_to_xyz_d65(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- D50_to_D65
  local M_matrix = {
    { 0.955473421488075, -0.02309845494876471, 0.06325924320057072 },
    { -0.0283697093338637, 1.0099953980813041, 0.021041441191917323 },
    { 0.012314014864481998, -0.020507649298898964, 1.330365926242124 },
  }

  ---@type number[]
  local coords = {}
  for idx, c in ipairs(color[2]) do
    coords[idx] = none_to_zero(c)
  end

  local xyz_d65_coords = multiply_matrices(M_matrix, coords) --[[@as number[] ]]
  return { "xyz-d65", xyz_d65_coords, color[3] } --[[@as xyz_d65]]
end

---@param color xyz
---@return xyz_d65
function M.xyz_to_xyz_d65(color)
  return { "xyz-d65", color[2], color[3] } --[[@as xyz_d65]]
end

---@param color xyz_d65
---@return xyz
function M.xyz_d65_to_xyz(color)
  return { "xyz", color[2], color[3] } --[[@as xyz]]
end

local CONVERSIONS_BY_COLORSPACE = {
  -- RGB family
  ["rgb"] = { { "srgb", M.rgb_to_srgb } },
  ["srgb"] = {
    { "rgb", M.srgb_to_rgb },
    { "hsl", M.srgb_to_hsl },
    { "hwb", M.srgb_to_hwb },
    { "srgb-linear", M.srgb_to_srgb_linear },
  },
  ["hsl"] = { { "srgb", M.hsl_to_srgb } },
  ["hwb"] = { { "srgb", M.hwb_to_srgb } },
  ["srgb-linear"] = { { "srgb", M.srgb_linear_to_srgb }, { "xyz-d65", M.srgb_linear_to_xyz_d65 } },

  -- Display P3 family
  ["display-p3"] = { { "display-p3-linear", M.display_p3_to_display_p3_linear } },
  ["display-p3-linear"] = {
    { "display-p3", M.display_p3_linear_to_display_p3 },
    { "xyz-d65", M.display_p3_linear_to_xyz_d65 },
  },

  -- A98 RGB family
  ["a98-rgb"] = { { "a98-rgb-linear", M.a98_rgb_to_a98_rgb_linear } },
  ["a98-rgb-linear"] = { { "a98-rgb", M.a98_rgb_linear_to_a98_rgb }, { "xyz-d65", M.a98_rgb_linear_to_xyz_d65 } },

  -- ProPhoto RGB family
  ["prophoto-rgb"] = { { "prophoto-rgb-linear", M.prophoto_rgb_to_prophoto_rgb_linear } },
  ["prophoto-rgb-linear"] = {
    { "prophoto-rgb", M.prophoto_rgb_linear_to_prophoto_rgb },
    { "xyz-d50", M.prophoto_rgb_linear_to_xyz_d50 },
  },

  -- Rec2020 family
  ["rec2020"] = { { "rec2020-linear", M.rec2020_to_rec2020_linear } },
  ["rec2020-linear"] = { { "rec2020", M.rec2020_linear_to_rec2020 }, { "xyz-d65", M.rec2020_linear_to_xyz_d65 } },

  -- Lab family
  ["lab"] = { { "lch", M.lab_to_lch }, { "xyz-d50", M.lab_to_xyz_d50 } },
  ["lch"] = { { "lab", M.lch_to_lab } },

  -- OKLab family
  ["oklab"] = { { "oklch", M.oklab_to_oklch }, { "xyz-d65", M.oklab_to_xyz_d65 } },
  ["oklch"] = { { "oklab", M.oklch_to_oklab } },

  -- XYZ family
  ["xyz"] = { { "xyz-d65", M.xyz_to_xyz_d65 } },
  ["xyz-d65"] = {
    { "xyz", M.xyz_d65_to_xyz },
    { "srgb-linear", M.xyz_d65_to_srgb_linear },
    { "display-p3-linear", M.xyz_d65_to_display_p3_linear },
    { "a98-rgb-linear", M.xyz_d65_to_a98_rgb_linear },
    { "rec2020-linear", M.xyz_d65_to_rec2020_linear },
    { "oklab", M.xyz_d65_to_oklab },
    { "xyz-d50", M.xyz_d65_to_xyz_d50 },
  },
  ["xyz-d50"] = {
    { "xyz-d65", M.xyz_d50_to_xyz_d65 },
    { "prophoto-rgb-linear", M.xyz_d50_to_prophoto_rgb_linear },
    { "lab", M.xyz_d50_to_lab },
  },
}

---@param a colorspace
---@param b colorspace
---@return colorspace_conversion[]
function M.get_conversions(a, b)
  if a == b then
    return {}
  end

  -- Find path using BFS
  local queue = { { a, {} } }
  local visited = { [a] = true }

  while #queue > 0 do
    local current_space, path = queue[1][1], queue[1][2]
    table.remove(queue, 1)

    if current_space == b then
      return path
    end

    local conversions = CONVERSIONS_BY_COLORSPACE[current_space] or {}
    for _, conversion in ipairs(conversions) do
      local next_space, conversion_func = conversion[1], conversion[2]
      if not visited[next_space] then
        visited[next_space] = true
        local new_path = {}
        for i, step in ipairs(path) do
          new_path[i] = step
        end
        new_path[#new_path + 1] = { current_space, next_space, conversion_func }
        table.insert(queue, { next_space, new_path })
      end
    end
  end

  -- No path found
  error(string.format("No conversion path found from %s to %s", a, b))
end

---@param color color
---@param to_colorspace colorspace
---@return color
function M.convert_color_to_colorspace(color, to_colorspace)
  local from_colorspace = color[1]

  if from_colorspace == to_colorspace then
    return color
  end

  local conversions = M.get_conversions(from_colorspace, to_colorspace)

  local current_color = color
  for _, conversion in ipairs(conversions) do
    local conversion_func = conversion[3]
    current_color = conversion_func(current_color)
  end

  return current_color
end

---@param color color
---@return color
function M.clone_color(color)
  return {
    color[1],
    { color[2][1], color[2][2], color[2][3] },
    color[3],
  }
end

---@param colorspace colorspace
---@return ColorSpace
function M.get_colorspace(colorspace)
  for _, cs in ipairs(M.ALL_COLORSPACES) do
    if cs.colorspace == colorspace then
      return cs
    end
  end

  error(string.format("unknown colorspace %s", colorspace))
end

---@param color color
---@return boolean
function M.is_in_gamut(color)
  local colorspace = color[1]
  local colorspace_def = M.get_colorspace(colorspace)
  local gamut_colorspace = colorspace_def.gamut_colorspace
  local gamut_colorspace_def = M.get_colorspace(gamut_colorspace)

  -- Convert to gamut colorspace if needed
  local gamut_color = color
  if colorspace ~= gamut_colorspace then
    gamut_color = M.convert_color_to_colorspace(color, gamut_colorspace)
  end

  -- Check if all coordinates are within range
  for i, coord in ipairs(gamut_color[2]) do
    if type(coord) == "number" then
      local range = gamut_colorspace_def.coords[i].range
      if not range.is_unbounded then
        if coord < range.min or coord > range.max then
          return false
        end
      end
    end
  end

  return true
end

---@param color color
---@param target_colorspace colorspace
---@return color
local function clip_to_gamut(color, target_colorspace)
  local converted = M.convert_color_to_colorspace(color, target_colorspace)
  local colorspace_def = M.get_colorspace(target_colorspace)

  -- Clip coordinates to range
  local clipped_coords = {}
  for i, coord in ipairs(converted[2]) do
    if type(coord) == "number" then
      local range = colorspace_def.coords[i].range
      if not range.is_unbounded then
        clipped_coords[i] = math.max(range.min, math.min(range.max, coord))
      else
        clipped_coords[i] = coord
      end
    else
      clipped_coords[i] = coord
    end
  end

  return { converted[1], clipped_coords, converted[3] }
end

---@param color1 color
---@param color2 color
---@return number
local function deltaEOK(color1, color2)
  local oklab1 = M.convert_color_to_colorspace(color1, "oklab")
  local oklab2 = M.convert_color_to_colorspace(color2, "oklab")

  local L1 = none_to_zero(oklab1[2][1])
  local a1 = none_to_zero(oklab1[2][2])
  local b1 = none_to_zero(oklab1[2][3])

  local L2 = none_to_zero(oklab2[2][1])
  local a2 = none_to_zero(oklab2[2][2])
  local b2 = none_to_zero(oklab2[2][3])

  local deltaL = L1 - L2
  local deltaA = a1 - a2
  local deltaB = b1 - b2

  return math.sqrt(deltaL * deltaL + deltaA * deltaA + deltaB * deltaB)
end

---@param color color
---@param target_colorspace colorspace
---@return color
function M.css_gamut_map(color, target_colorspace)
  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 1
  local target_color = M.convert_color_to_colorspace(color, target_colorspace)
  if M.is_in_gamut(target_color) then
    return target_color
  end

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 2
  local oklch_color = M.convert_color_to_colorspace(color, "oklch")

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 3
  local oklch_coords = oklch_color[2]
  local oklch_L = none_to_zero(oklch_coords[1])
  if oklch_L >= 1 then
    local white = {
      "oklab",
      { 1, 0, 0 },
      oklch_color[3],
    }
    -- The spec does not say we should clip but it is observed that
    -- converting this white to some colorspaces could result in
    -- slightly out-of-gamut values due to floating point calculation.
    return clip_to_gamut(white, target_colorspace)
  end

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 4
  if oklch_L <= 0 then
    local black = {
      "oklab",
      { 0, 0, 0 },
      oklch_color[3],
    }
    -- The spec does not say we should clip but it is observed that
    -- converting this white to some colorspaces could result in
    -- slightly out-of-gamut values due to floating point calculation.
    return clip_to_gamut(black, target_colorspace)
  end

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 5 defines isGamut(color)

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 6
  local target_oklch_color = M.convert_color_to_colorspace(oklch_color, target_colorspace)
  if M.is_in_gamut(target_oklch_color) then
    return target_oklch_color
  end

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 7 defines deltaEOK(color1, color2)

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 8
  local JND = 0.02

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 9
  local epsilon = 0.0001

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 10 defines clip(color)

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 11
  local current = M.clone_color(oklch_color)

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 12
  local clipped = clip_to_gamut(current, target_colorspace)

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 13
  local E = deltaEOK(clipped, current)

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 14
  if E < JND then
    return clipped
  end

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 15
  local min = 0

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 16
  local max = none_to_zero(oklch_color[2][2])

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 17
  local min_inGamut = true

  -- https://www.w3.org/TR/css-color-4/#binsearch
  -- Step 18
  while (max - min) > epsilon do
    -- https://www.w3.org/TR/css-color-4/#binsearch
    -- Step 18.1
    local chroma = (min + max) / 2
    -- https://www.w3.org/TR/css-color-4/#binsearch
    -- Step 18.2
    current[2][2] = chroma

    local target_current = M.convert_color_to_colorspace(current, target_colorspace)
    if min_inGamut and M.is_in_gamut(target_current) then
      -- https://www.w3.org/TR/css-color-4/#binsearch
      -- Step 18.3
      min = chroma
    else
      -- https://www.w3.org/TR/css-color-4/#binsearch
      -- Step 18.4.1
      clipped = clip_to_gamut(current, target_colorspace)
      -- https://www.w3.org/TR/css-color-4/#binsearch
      -- Step 18.4.2
      E = deltaEOK(clipped, current)

      -- https://www.w3.org/TR/css-color-4/#binsearch
      -- Step 18.4.3
      if E < JND then
        -- https://www.w3.org/TR/css-color-4/#binsearch
        -- Step 18.4.3.1
        if JND - E < epsilon then
          return clipped
        end

        -- https://www.w3.org/TR/css-color-4/#binsearch
        -- Step 18.4.3.2.1
        min_inGamut = false
        -- https://www.w3.org/TR/css-color-4/#binsearch
        -- Step 18.4.3.2.2
        min = chroma
      else
        -- https://www.w3.org/TR/css-color-4/#binsearch
        -- Step 18.4.4
        max = chroma
      end
    end
  end

  return clipped
end

---@param alpha number|"none"|nil
---@return number
local function get_alpha(alpha)
  if alpha == nil then
    return 1
  end
  if type(alpha) == "number" then
    return math.max(0, math.min(1, alpha))
  end
  return 0
end

---@param source color
---@param backdrop color
---@return color
function M.alpha_blending_over(source, backdrop)
  ---@type color
  local result

  local source_alpha = get_alpha(source[3])
  local backdrop_alpha = get_alpha(backdrop[3])

  if source_alpha == 0 then
    result = backdrop
  elseif source_alpha == 1 or backdrop_alpha == 0 then
    result = source
  else
    local source_xyz = M.convert_color_to_colorspace(source, "xyz-d65")
    local backdrop_xyz = M.convert_color_to_colorspace(backdrop, "xyz-d65")

    local coords = {}
    for i = 1, 3, 1 do
      local s = none_to_zero(source_xyz[2][i])
      local b = none_to_zero(backdrop_xyz[2][i])

      -- https://www.w3.org/TR/compositing/#simplealphacompositing
      coords[i] = s * source_alpha + b * backdrop_alpha * (1 - source_alpha)
    end
    -- https://www.w3.org/TR/compositing/#simplealphacompositing
    local result_alpha = source_alpha + backdrop_alpha * (1 - source_alpha)

    result = {
      "xyz-d65",
      coords,
      result_alpha,
    }
  end

  return M.convert_color_to_colorspace(result, source[1])
end

---@param background color
---@param foreground color
---@return number
function M.contrast_apca(background, foreground)
  -- APCA constants based on https://github.com/color-js/color.js/blob/v0.6.0-alpha.1/src/contrast/APCA.js
  local normBG = 0.56
  local normTXT = 0.57
  local revTXT = 0.62
  local revBG = 0.65

  local blkThrs = 0.022
  local blkClmp = 1.414
  local loClip = 0.1
  local deltaYmin = 0.0005

  local scaleBoW = 1.14
  local loBoWoffset = 0.027
  local scaleWoB = 1.14
  -- local loWoBoffset = 0.027

  ---@param Y number
  ---@return number
  local function fclamp(Y)
    if Y >= blkThrs then
      return Y
    end
    return Y + math.pow(blkThrs - Y, blkClmp)
  end

  ---@param val number
  ---@return number
  local function linearize(val)
    local sign = val < 0 and -1 or 1
    local abs = math.abs(val)
    return sign * math.pow(abs, 2.4)
  end

  -- Convert colors to sRGB
  local fg_srgb = M.convert_color_to_colorspace(foreground, "srgb")
  local bg_srgb = M.convert_color_to_colorspace(background, "srgb")

  -- Calculate luminance using linearization and weighted coefficients
  local fg_coords = fg_srgb[2]
  local R = none_to_zero(fg_coords[1])
  local G = none_to_zero(fg_coords[2])
  local B = none_to_zero(fg_coords[3])
  local lumTxt = linearize(R) * 0.2126729 + linearize(G) * 0.7151522 + linearize(B) * 0.0721750

  local bg_coords = bg_srgb[2]
  R = none_to_zero(bg_coords[1])
  G = none_to_zero(bg_coords[2])
  B = none_to_zero(bg_coords[3])
  local lumBg = linearize(R) * 0.2126729 + linearize(G) * 0.7151522 + linearize(B) * 0.0721750

  local Ytxt = fclamp(lumTxt)
  local Ybg = fclamp(lumBg)
  local BoW = Ybg > Ytxt

  local C
  local S
  if math.abs(Ybg - Ytxt) < deltaYmin then
    C = 0
  else
    if BoW then
      S = math.pow(Ybg, normBG) - math.pow(Ytxt, normTXT)
      C = S * scaleBoW
    else
      S = math.pow(Ybg, revBG) - math.pow(Ytxt, revTXT)
      C = S * scaleWoB
    end
  end

  local Sapc
  if math.abs(C) < loClip then
    Sapc = 0
  elseif C > 0 then
    Sapc = C - loBoWoffset
  else
    Sapc = C + loBoWoffset
  end

  return Sapc * 100
end

---@type table<string, color>
local NAMED_COLORS = {
  ["transparent"] = { "rgb", { 0, 0, 0 }, 0 },
  ["aliceblue"] = { "rgb", { 240, 248, 255 } },
  ["antiquewhite"] = { "rgb", { 250, 235, 215 } },
  ["aqua"] = { "rgb", { 0, 255, 255 } },
  ["aquamarine"] = { "rgb", { 127, 255, 212 } },
  ["azure"] = { "rgb", { 240, 255, 255 } },
  ["beige"] = { "rgb", { 245, 245, 220 } },
  ["bisque"] = { "rgb", { 255, 228, 196 } },
  ["black"] = { "rgb", { 0, 0, 0 } },
  ["blanchedalmond"] = { "rgb", { 255, 235, 205 } },
  ["blue"] = { "rgb", { 0, 0, 255 } },
  ["blueviolet"] = { "rgb", { 138, 43, 226 } },
  ["brown"] = { "rgb", { 165, 42, 42 } },
  ["burlywood"] = { "rgb", { 222, 184, 135 } },
  ["cadetblue"] = { "rgb", { 95, 158, 160 } },
  ["chartreuse"] = { "rgb", { 127, 255, 0 } },
  ["chocolate"] = { "rgb", { 210, 105, 30 } },
  ["coral"] = { "rgb", { 255, 127, 80 } },
  ["cornflowerblue"] = { "rgb", { 100, 149, 237 } },
  ["cornsilk"] = { "rgb", { 255, 248, 220 } },
  ["crimson"] = { "rgb", { 220, 20, 60 } },
  ["cyan"] = { "rgb", { 0, 255, 255 } },
  ["darkblue"] = { "rgb", { 0, 0, 139 } },
  ["darkcyan"] = { "rgb", { 0, 139, 139 } },
  ["darkgoldenrod"] = { "rgb", { 184, 134, 11 } },
  ["darkgray"] = { "rgb", { 169, 169, 169 } },
  ["darkgreen"] = { "rgb", { 0, 100, 0 } },
  ["darkgrey"] = { "rgb", { 169, 169, 169 } },
  ["darkkhaki"] = { "rgb", { 189, 183, 107 } },
  ["darkmagenta"] = { "rgb", { 139, 0, 139 } },
  ["darkolivegreen"] = { "rgb", { 85, 107, 47 } },
  ["darkorange"] = { "rgb", { 255, 140, 0 } },
  ["darkorchid"] = { "rgb", { 153, 50, 204 } },
  ["darkred"] = { "rgb", { 139, 0, 0 } },
  ["darksalmon"] = { "rgb", { 233, 150, 122 } },
  ["darkseagreen"] = { "rgb", { 143, 188, 143 } },
  ["darkslateblue"] = { "rgb", { 72, 61, 139 } },
  ["darkslategray"] = { "rgb", { 47, 79, 79 } },
  ["darkslategrey"] = { "rgb", { 47, 79, 79 } },
  ["darkturquoise"] = { "rgb", { 0, 206, 209 } },
  ["darkviolet"] = { "rgb", { 148, 0, 211 } },
  ["deeppink"] = { "rgb", { 255, 20, 147 } },
  ["deepskyblue"] = { "rgb", { 0, 191, 255 } },
  ["dimgray"] = { "rgb", { 105, 105, 105 } },
  ["dimgrey"] = { "rgb", { 105, 105, 105 } },
  ["dodgerblue"] = { "rgb", { 30, 144, 255 } },
  ["firebrick"] = { "rgb", { 178, 34, 34 } },
  ["floralwhite"] = { "rgb", { 255, 250, 240 } },
  ["forestgreen"] = { "rgb", { 34, 139, 34 } },
  ["fuchsia"] = { "rgb", { 255, 0, 255 } },
  ["gainsboro"] = { "rgb", { 220, 220, 220 } },
  ["ghostwhite"] = { "rgb", { 248, 248, 255 } },
  ["gold"] = { "rgb", { 255, 215, 0 } },
  ["goldenrod"] = { "rgb", { 218, 165, 32 } },
  ["gray"] = { "rgb", { 128, 128, 128 } },
  ["green"] = { "rgb", { 0, 128, 0 } },
  ["greenyellow"] = { "rgb", { 173, 255, 47 } },
  ["grey"] = { "rgb", { 128, 128, 128 } },
  ["honeydew"] = { "rgb", { 240, 255, 240 } },
  ["hotpink"] = { "rgb", { 255, 105, 180 } },
  ["indianred"] = { "rgb", { 205, 92, 92 } },
  ["indigo"] = { "rgb", { 75, 0, 130 } },
  ["ivory"] = { "rgb", { 255, 255, 240 } },
  ["khaki"] = { "rgb", { 240, 230, 140 } },
  ["lavender"] = { "rgb", { 230, 230, 250 } },
  ["lavenderblush"] = { "rgb", { 255, 240, 245 } },
  ["lawngreen"] = { "rgb", { 124, 252, 0 } },
  ["lemonchiffon"] = { "rgb", { 255, 250, 205 } },
  ["lightblue"] = { "rgb", { 173, 216, 230 } },
  ["lightcoral"] = { "rgb", { 240, 128, 128 } },
  ["lightcyan"] = { "rgb", { 224, 255, 255 } },
  ["lightgoldenrodyellow"] = { "rgb", { 250, 250, 210 } },
  ["lightgray"] = { "rgb", { 211, 211, 211 } },
  ["lightgreen"] = { "rgb", { 144, 238, 144 } },
  ["lightgrey"] = { "rgb", { 211, 211, 211 } },
  ["lightpink"] = { "rgb", { 255, 182, 193 } },
  ["lightsalmon"] = { "rgb", { 255, 160, 122 } },
  ["lightseagreen"] = { "rgb", { 32, 178, 170 } },
  ["lightskyblue"] = { "rgb", { 135, 206, 250 } },
  ["lightslategray"] = { "rgb", { 119, 136, 153 } },
  ["lightslategrey"] = { "rgb", { 119, 136, 153 } },
  ["lightsteelblue"] = { "rgb", { 176, 196, 222 } },
  ["lightyellow"] = { "rgb", { 255, 255, 224 } },
  ["lime"] = { "rgb", { 0, 255, 0 } },
  ["limegreen"] = { "rgb", { 50, 205, 50 } },
  ["linen"] = { "rgb", { 250, 240, 230 } },
  ["magenta"] = { "rgb", { 255, 0, 255 } },
  ["maroon"] = { "rgb", { 128, 0, 0 } },
  ["mediumaquamarine"] = { "rgb", { 102, 205, 170 } },
  ["mediumblue"] = { "rgb", { 0, 0, 205 } },
  ["mediumorchid"] = { "rgb", { 186, 85, 211 } },
  ["mediumpurple"] = { "rgb", { 147, 112, 219 } },
  ["mediumseagreen"] = { "rgb", { 60, 179, 113 } },
  ["mediumslateblue"] = { "rgb", { 123, 104, 238 } },
  ["mediumspringgreen"] = { "rgb", { 0, 250, 154 } },
  ["mediumturquoise"] = { "rgb", { 72, 209, 204 } },
  ["mediumvioletred"] = { "rgb", { 199, 21, 133 } },
  ["midnightblue"] = { "rgb", { 25, 25, 112 } },
  ["mintcream"] = { "rgb", { 245, 255, 250 } },
  ["mistyrose"] = { "rgb", { 255, 228, 225 } },
  ["moccasin"] = { "rgb", { 255, 228, 181 } },
  ["navajowhite"] = { "rgb", { 255, 222, 173 } },
  ["navy"] = { "rgb", { 0, 0, 128 } },
  ["oldlace"] = { "rgb", { 253, 245, 230 } },
  ["olive"] = { "rgb", { 128, 128, 0 } },
  ["olivedrab"] = { "rgb", { 107, 142, 35 } },
  ["orange"] = { "rgb", { 255, 165, 0 } },
  ["orangered"] = { "rgb", { 255, 69, 0 } },
  ["orchid"] = { "rgb", { 218, 112, 214 } },
  ["palegoldenrod"] = { "rgb", { 238, 232, 170 } },
  ["palegreen"] = { "rgb", { 152, 251, 152 } },
  ["paleturquoise"] = { "rgb", { 175, 238, 238 } },
  ["palevioletred"] = { "rgb", { 219, 112, 147 } },
  ["papayawhip"] = { "rgb", { 255, 239, 213 } },
  ["peachpuff"] = { "rgb", { 255, 218, 185 } },
  ["peru"] = { "rgb", { 205, 133, 63 } },
  ["pink"] = { "rgb", { 255, 192, 203 } },
  ["plum"] = { "rgb", { 221, 160, 221 } },
  ["powderblue"] = { "rgb", { 176, 224, 230 } },
  ["purple"] = { "rgb", { 128, 0, 128 } },
  ["rebeccapurple"] = { "rgb", { 102, 51, 153 } },
  ["red"] = { "rgb", { 255, 0, 0 } },
  ["rosybrown"] = { "rgb", { 188, 143, 143 } },
  ["royalblue"] = { "rgb", { 65, 105, 225 } },
  ["saddlebrown"] = { "rgb", { 139, 69, 19 } },
  ["salmon"] = { "rgb", { 250, 128, 114 } },
  ["sandybrown"] = { "rgb", { 244, 164, 96 } },
  ["seagreen"] = { "rgb", { 46, 139, 87 } },
  ["seashell"] = { "rgb", { 255, 245, 238 } },
  ["sienna"] = { "rgb", { 160, 82, 45 } },
  ["silver"] = { "rgb", { 192, 192, 192 } },
  ["skyblue"] = { "rgb", { 135, 206, 235 } },
  ["slateblue"] = { "rgb", { 106, 90, 205 } },
  ["slategray"] = { "rgb", { 112, 128, 144 } },
  ["slategrey"] = { "rgb", { 112, 128, 144 } },
  ["snow"] = { "rgb", { 255, 250, 250 } },
  ["springgreen"] = { "rgb", { 0, 255, 127 } },
  ["steelblue"] = { "rgb", { 70, 130, 180 } },
  ["tan"] = { "rgb", { 210, 180, 140 } },
  ["teal"] = { "rgb", { 0, 128, 128 } },
  ["thistle"] = { "rgb", { 216, 191, 216 } },
  ["tomato"] = { "rgb", { 255, 99, 71 } },
  ["turquoise"] = { "rgb", { 64, 224, 208 } },
  ["violet"] = { "rgb", { 238, 130, 238 } },
  ["wheat"] = { "rgb", { 245, 222, 179 } },
  ["white"] = { "rgb", { 255, 255, 255 } },
  ["whitesmoke"] = { "rgb", { 245, 245, 245 } },
  ["yellow"] = { "rgb", { 255, 255, 0 } },
  ["yellowgreen"] = { "rgb", { 154, 205, 50 } },
}

---@param name string
---@return color
function M.named_color(name)
  name = string.lower(name)
  local c = NAMED_COLORS[name]
  if c == nil then
    error(string.format("not a named color: %s", name))
  end
  return c
end

return M
