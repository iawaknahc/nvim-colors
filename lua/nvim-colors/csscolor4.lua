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

--- @alias range_0_04 number
--- @alias range_0_1 number
--- @alias range_0_100 number
--- @alias range_0_125 number
--- @alias range_0_150 number
--- @alias range_0_255 number
--- @alias range_0_360 number

--- @class rgb
--- @field [1] "rgb"
--- @field [2] ("none"|range_0_255)[]
--- @field [3] "none"|range_0_1|nil

--- @class (exact) hsl_coords
--- @field [1] "none"|range_0_360
--- @field [2] "none"|range_0_100
--- @field [3] "none"|range_0_100

--- @class hsl
--- @field [1] "hsl"
--- @field [2] hsl_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) hwb_coords
--- @field [1] "none"|range_0_360
--- @field [2] "none"|range_0_100
--- @field [3] "none"|range_0_100

--- @class hwb
--- @field [1] "hwb"
--- @field [2] hwb_coords
--- @field [3] "none"|range_0_1|nil

--- @class (exact) lab_coords
--- @field [1] "none"|range_0_100
--- @field [2] "none"|range_0_125
--- @field [3] "none"|range_0_125

--- @class lab
--- @field [1] "lab"
--- @field [2] lab_coords
--- @field [3] "none"|range_0_1|nil

--- @class lch_coords
--- @field [1] "none"|range_0_100
--- @field [2] "none"|range_0_150
--- @field [3] "none"|range_0_360

--- @class lch
--- @field [1] "lch"
--- @field [2] lch_coords
--- @field [3] "none"|range_0_1|nil

--- @class oklab_coords
--- @field [1] "none"|range_0_1
--- @field [2] "none"|range_0_04
--- @field [3] "none"|range_0_04

--- @class oklab
--- @field [1] "oklab"
--- @field [2] oklab_coords
--- @field [3] "none"|range_0_1|nil

--- @class oklch_coords
--- @field [1] "none"|range_0_1
--- @field [2] "none"|range_0_04
--- @field [3] "none"|range_0_360

--- @class oklch
--- @field [1] "oklch"
--- @field [2] oklch_coords
--- @field [3] "none"|range_0_1|nil

--- @class srgb
--- @field [1] "srgb"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class srgb_linear
--- @field [1] "srgb-linear"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class display_p3
--- @field [1] "display-p3"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class a98_rgb
--- @field [1] "a98-rgb"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class prophoto_rgb
--- @field [1] "prophoto-rgb"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class rec2020
--- @field [1] "rec2020"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class xyz
--- @field [1] "xyz"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class xyz_d50
--- @field [1] "xyz-d50"
--- @field [2] ("none"|range_0_1)[]
--- @field [3] "none"|range_0_1|nil

--- @class xyz_d65
--- @field [1] "xyz-d65"
--- @field [2] ("none"|range_0_1)[]
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
    local n = M.percentage2number(p, range)
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
    local n = M.percentage2number(p, 100)
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
function M.rgb2srgb(color)
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
function M.srgb2rgb(color)
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
function M.hsl2srgb(color)
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
function M.srgb2hsl(color)
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

--- @param color srgb
--- @return srgb_linear
function M.srgb2srgb_linear(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- lin_sRGB
  local coords = {}
  for idx, c in ipairs(color[2]) do
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
      coords[idx] = cl
    else
      coords[idx] = c
    end
  end
  return { "srgb-linear", coords, color[3] } --[[@as srgb_linear]]
end

--- @param color srgb_linear
--- @return srgb
function M.srgb_linear2srgb(color)
  -- https://www.w3.org/TR/css-color-4/#color-conversion-code
  -- gam_sRGB

  local coords = {}
  for idx, cl in ipairs(color[2]) do
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
      coords[idx] = c
    else
      coords[idx] = cl
    end
  end
  return { "srgb", coords, color[3] } --[[@as srgb]]
end

--- @param color hwb
--- @return srgb
function M.hwb2srgb(color)
  -- https://www.w3.org/TR/css-color-4/#hwb-to-rgb
  local hue = none_to_zero(color[2][1]) % 360
  local white = none_to_zero(color[2][2]) / 100
  local black = none_to_zero(color[2][3]) / 100

  local coords = {}
  if white + black >= 1 then
    local gray = white / (white + black)
    coords = { gray, gray, gray }
  else
    local srgb_coords = M.hsl2srgb({ "hsl", { hue, 100, 50 } })[2]
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
function M.srgb2hwb(color)
  -- https://www.w3.org/TR/css-color-4/#rgb-to-hwb
  local red = none_to_zero(color[2][1])
  local green = none_to_zero(color[2][2])
  local blue = none_to_zero(color[2][3])
  local hsl_coords = M.srgb2hsl(color)[2]
  local white = math.min(red, green, blue)
  local black = 1 - math.max(red, green, blue)
  local coords = { hsl_coords[1], white * 100, black * 100 }
  return { "hwb", coords, color[3] }
end

--- @param color lab
--- @return lch
function M.lab2lch(color)
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
function M.lch2lab(color)
  local C = none_to_zero(color[2][2])
  local hue = none_to_zero(color[2][3])

  local a = C * math.cos(hue * math.pi / 180)
  local b = C * math.sin(hue * math.pi / 180)
  local coords = { color[2][1], a, b }
  return { "lab", coords, color[3] }
end

return M
