local csscolor4 = require("nvim-colors.csscolor4")
local say = require("say")

say:set_namespace("en")
say:set("assertion.are_same_color.positive", "Expected colors to be equal.\nPassed in:\n%s\nExpected:\n%s")
say:set("assertion.are_same_color.negative", "Expected colors not to be equal.\nPassed in:\n%s\nExpected:\n%s")

local function near(expected, actual, tolerance)
  return (actual >= expected - tolerance and actual <= expected + tolerance)
end

local function same_color(_, arguments, level)
  level = (level or 1) + 1

  local expected_color = arguments[1]
  local actual_color = arguments[2]

  if expected_color == nil then
    assert(actual_color == nil, "expected == nil but actual ~= nil", level)
    return true
  end

  assert(actual_color ~= nil, "expected ~= nil but actual == nil", level)

  -- colorspace must equal.
  assert(expected_color[1] == actual_color[1], string.format("%s ~= %s", expected_color[1], actual_color[1]), level)

  local tolerance = 0.00001

  -- The coordinates must near.
  for idx, expected_coord in ipairs(expected_color[2]) do
    local actual_coord = actual_color[2][idx]
    if type(expected_coord) == "string" then
      assert(
        expected_coord == actual_coord,
        string.format("%s ~= %s", tostring(expected_coord), tostring(actual_coord)),
        level
      )
    else
      assert(
        near(expected_coord, actual_coord, tolerance),
        string.format("%s ~= %s (%s)", tostring(expected_coord), tostring(actual_coord), tostring(tolerance)),
        level
      )
    end
  end

  -- The alpha component must near.
  local expected_alpha = expected_color[3]
  local actual_alpha = actual_color[3]

  if expected_alpha == nil then
    assert(actual_alpha == nil, "expected_alpha == nil but actual_alpha ~= nil", level)
    return true
  end

  if type(expected_alpha) == "string" then
    assert(
      expected_alpha == actual_alpha,
      string.format("%s ~= %s", tostring(expected_alpha), tostring(actual_alpha)),
      level
    )
  else
    assert(
      near(expected_alpha, actual_alpha, tolerance),
      string.format("%s ~= %s (%s)", tostring(expected_alpha), tostring(actual_alpha), tostring(tolerance)),
      level
    )
  end

  return true
end

assert:register("assertion", "same_color", same_color, "assertion.same_color.positive", "assertion.same_color.negative")

describe("angle", function()
  it("convert from deg to deg", function()
    assert.same({ 90, "deg" }, csscolor4.to_deg({ 100, "grad" }))
  end)
  it("convert from rad to deg", function()
    assert.same({ 90, "deg" }, csscolor4.to_deg({ 2 * math.pi / 4, "rad" }))
  end)
  it("convert from turn to deg", function()
    assert.same({ 90, "deg" }, csscolor4.to_deg({ 0.25, "turn" }))
  end)
end)

describe("percentage", function()
  it("convert to number", function()
    assert.same(1, csscolor4.percentage2number({ 100, "percentage" }))
    assert.same(0, csscolor4.percentage2number({ 0, "percentage" }))
    assert.same(-0.1, csscolor4.percentage2number({ -10, "percentage" }))

    assert.same(255, csscolor4.percentage2number({ 100, "percentage" }, 255))
    assert.same(0, csscolor4.percentage2number({ 0, "percentage" }, 255))
    assert.same(-25.5, csscolor4.percentage2number({ -10, "percentage" }, 255))
  end)
end)

describe("parse_value", function()
  it("parse none", function()
    assert.same("none", csscolor4.parse_value("none"))
    assert.same("none", csscolor4.parse_value("None"))
    assert.same("none", csscolor4.parse_value("NONE"))
    assert.same("none", csscolor4.parse_value("nONE"))
  end)
  it("parse number", function()
    assert.same(0, csscolor4.parse_value("0"))
    assert.same(1, csscolor4.parse_value("1"))
    assert.same(1, csscolor4.parse_value("+1"))
    assert.same(-1, csscolor4.parse_value("-1"))
    assert.same(1.1, csscolor4.parse_value("1.1"))
    assert.same(0.1, csscolor4.parse_value(".1"))
    assert.same(0.123, csscolor4.parse_value(".123"))
    assert.same(1000000, csscolor4.parse_value("1e6"))
    assert.same(-1000, csscolor4.parse_value("-1e3"))
  end)
  it("parse percentage", function()
    assert.same({ 0, "percentage" }, csscolor4.parse_value("0%"))
    assert.same({ 1, "percentage" }, csscolor4.parse_value("1%"))
    assert.same({ 1, "percentage" }, csscolor4.parse_value("+1%"))
    assert.same({ -1, "percentage" }, csscolor4.parse_value("-1%"))
    assert.same({ 1.1, "percentage" }, csscolor4.parse_value("1.1%"))
    assert.same({ 0.1, "percentage" }, csscolor4.parse_value(".1%"))
    assert.same({ 0.123, "percentage" }, csscolor4.parse_value(".123%"))
    assert.same({ 1000000, "percentage" }, csscolor4.parse_value("1e6%"))
    assert.same({ -1000, "percentage" }, csscolor4.parse_value("-1e3%"))
  end)
  it("parse angle", function()
    assert.same({ 0, "deg" }, csscolor4.parse_value("0deg"))
    assert.same({ 0, "grad" }, csscolor4.parse_value("0grad"))
    assert.same({ 0, "rad" }, csscolor4.parse_value("0rad"))
    assert.same({ 0, "turn" }, csscolor4.parse_value("0turn"))
  end)
  it("return nil for everything else", function()
    assert.same(nil, csscolor4.parse_value(""))
    assert.same(nil, csscolor4.parse_value("foobar"))
    assert.same(nil, csscolor4.parse_value("0X20"))
    assert.same(nil, csscolor4.parse_value("0x20"))
  end)
end)

describe("rgb", function()
  it("parse rgb", function()
    assert.same_color(nil, csscolor4.rgb("", "", ""))

    assert.same_color({ "rgb", { "none", "none", "none" } }, csscolor4.rgb("none", "none", "none"))
    assert.same_color({ "rgb", { "none", "none", "none" }, "none" }, csscolor4.rgb("none", "none", "none", "none"))

    assert.same_color({ "rgb", { "none", "none", "none" } }, csscolor4.rgb("NONE", "NONE", "NONE"))
    assert.same_color({ "rgb", { "none", "none", "none" }, "none" }, csscolor4.rgb("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "rgb", { 0, 0, 0 } }, csscolor4.rgb("0", "0", "0"))
    assert.same_color({ "rgb", { 255, 255, 255 } }, csscolor4.rgb("255", "255", "255"))
    assert.same_color({ "rgb", { 51, 102, 153 } }, csscolor4.rgb("51", "102", "153"))
    assert.same_color({ "rgb", { 51, 102, 153 }, 0.5 }, csscolor4.rgb("51", "102", "153", "50%"))
    assert.same_color({ "rgb", { 51, 102, 153 }, 0.5 }, csscolor4.rgb("51", "102", "153", "0.5"))
    assert.same_color({ "rgb", { 255, 255, 255 }, 1 }, csscolor4.rgb("300", "300", "300", "120%"))
    assert.same_color({ "rgb", { 0, 0, 0 } }, csscolor4.rgb("-51", "-102", "-153"))
    assert.same_color({ "rgb", { 0, 0, 0 }, 0 }, csscolor4.rgb("-51", "-102", "-153", "-10%"))
    assert.same_color({ "rgb", { 0, 0, 0 }, 0 }, csscolor4.rgb("-51", "-102", "-153", "-0.1"))

    assert.same_color({ "rgb", { 0, 0, 0 } }, csscolor4.rgb("0%", "0%", "0%"))
    assert.same_color({ "rgb", { 255, 255, 255 } }, csscolor4.rgb("100%", "100%", "100%"))
    assert.same_color({ "rgb", { 51, 102, 153 } }, csscolor4.rgb("20%", "40%", "60%"))
    assert.same_color({ "rgb", { 51, 102, 153 }, 0.5 }, csscolor4.rgb("20%", "40%", "60%", "50%"))
    assert.same_color({ "rgb", { 51, 102, 153 }, 0.5 }, csscolor4.rgb("20%", "40%", "60%", "0.5"))
    assert.same_color({ "rgb", { 255, 255, 255 }, 1 }, csscolor4.rgb("120%", "120%", "120%", "120%"))
    assert.same_color({ "rgb", { 0, 0, 0 } }, csscolor4.rgb("-20%", "-40%", "-60%"))
    assert.same_color({ "rgb", { 0, 0, 0 }, 0 }, csscolor4.rgb("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "rgb", { 0, 0, 0 }, 0 }, csscolor4.rgb("-20%", "-40%", "-60%", "-0.5"))
  end)
end)

describe("srgb", function()
  it("parse srgb", function()
    assert.same_color(nil, csscolor4.srgb("", "", ""))

    assert.same_color({ "srgb", { "none", "none", "none" } }, csscolor4.srgb("none", "none", "none"))
    assert.same_color({ "srgb", { "none", "none", "none" }, "none" }, csscolor4.srgb("none", "none", "none", "none"))

    assert.same_color({ "srgb", { "none", "none", "none" } }, csscolor4.srgb("NONE", "NONE", "NONE"))
    assert.same_color({ "srgb", { "none", "none", "none" }, "none" }, csscolor4.srgb("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "srgb", { 0, 0, 0 } }, csscolor4.srgb("0", "0", "0"))
    assert.same_color({ "srgb", { 1, 1, 1 } }, csscolor4.srgb("1", "1", "1"))
    assert.same_color({ "srgb", { 0.2, 0.4, 0.6 } }, csscolor4.srgb("0.2", "0.4", "0.6"))
    assert.same_color({ "srgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "srgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "srgb", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.srgb("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "srgb", { -0.2, -0.4, -0.6 } }, csscolor4.srgb("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "srgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "srgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "srgb", { 0, 0, 0 } }, csscolor4.srgb("0%", "0%", "0%"))
    assert.same_color({ "srgb", { 1, 1, 1 } }, csscolor4.srgb("100%", "100%", "100%"))
    assert.same_color({ "srgb", { 0.2, 0.4, 0.6 } }, csscolor4.srgb("20%", "40%", "60%"))
    assert.same_color({ "srgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb("20%", "40%", "60%", "50%"))
    assert.same_color({ "srgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb("20%", "40%", "60%", "0.5"))
    assert.same_color({ "srgb", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.srgb("120%", "140%", "160%", "120%"))
    assert.same_color({ "srgb", { -0.2, -0.4, -0.6 } }, csscolor4.srgb("-20%", "-40%", "-60%"))
    assert.same_color({ "srgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "srgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("hsl", function()
  it("parse hsl", function()
    assert.same_color(nil, csscolor4.hsl("", "", ""))

    assert.same_color({ "hsl", { "none", "none", "none" } }, csscolor4.hsl("none", "none", "none"))
    assert.same_color({ "hsl", { "none", "none", "none" }, "none" }, csscolor4.hsl("none", "none", "none", "none"))

    assert.same_color({ "hsl", { "none", "none", "none" } }, csscolor4.hsl("NONE", "NONE", "NONE"))
    assert.same_color({ "hsl", { "none", "none", "none" }, "none" }, csscolor4.hsl("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "hsl", { 0, 0, 0 } }, csscolor4.hsl("0", "0", "0"))
    assert.same_color({ "hsl", { 0, 100, 100 } }, csscolor4.hsl("360", "100", "100"))
    assert.same_color({ "hsl", { 72, 40, 60 } }, csscolor4.hsl("72", "40", "60"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("72", "40", "60", "50%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("72", "40", "60", "0.5"))
    assert.same_color({ "hsl", { 72, 140, 160 }, 1 }, csscolor4.hsl("432", "140", "160", "120%"))
    assert.same_color({ "hsl", { 288, 0, -60 } }, csscolor4.hsl("-72", "-40", "-60"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-72", "-40", "-60", "-10%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-72", "-40", "-60", "-0.1"))

    assert.same_color({ "hsl", { 0, 0, 0 } }, csscolor4.hsl("0deg", "0", "0"))
    assert.same_color({ "hsl", { 0, 100, 100 } }, csscolor4.hsl("360deg", "100", "100"))
    assert.same_color({ "hsl", { 72, 40, 60 } }, csscolor4.hsl("72deg", "40", "60"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("72deg", "40", "60", "50%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("72deg", "40", "60", "0.5"))
    assert.same_color({ "hsl", { 72, 140, 160 }, 1 }, csscolor4.hsl("432deg", "140", "160", "120%"))
    assert.same_color({ "hsl", { 288, 0, -60 } }, csscolor4.hsl("-72deg", "-40", "-60"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-72deg", "-40", "-60", "-10%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-72deg", "-40", "-60", "-0.1"))

    assert.same_color({ "hsl", { 0, 0, 0 } }, csscolor4.hsl("0grad", "0", "0"))
    assert.same_color({ "hsl", { 0, 100, 100 } }, csscolor4.hsl("400grad", "100", "100"))
    assert.same_color({ "hsl", { 72, 40, 60 } }, csscolor4.hsl("80grad", "40", "60"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("80grad", "40", "60", "50%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("80grad", "40", "60", "0.5"))
    assert.same_color({ "hsl", { 72, 140, 160 }, 1 }, csscolor4.hsl("480grad", "140", "160", "120%"))
    assert.same_color({ "hsl", { 288, 0, -60 } }, csscolor4.hsl("-80grad", "-40", "-60"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-80grad", "-40", "-60", "-10%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-80grad", "-40", "-60", "-0.1"))

    assert.same_color({ "hsl", { 0, 0, 0 } }, csscolor4.hsl("0rad", "0", "0"))
    assert.same_color({ "hsl", { 359.99998, 100, 100 } }, csscolor4.hsl("6.283185rad", "100", "100"))
    assert.same_color({ "hsl", { 72, 40, 60 } }, csscolor4.hsl("1.256637rad", "40", "60"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("1.256637rad", "40", "60", "50%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("1.256637rad", "40", "60", "0.5"))
    assert.same_color({ "hsl", { 72, 140, 160 }, 1 }, csscolor4.hsl("1.256637rad", "140", "160", "120%"))
    assert.same_color({ "hsl", { 288, 0, -60 } }, csscolor4.hsl("-1.256637rad", "-40", "-60"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-1.256637rad", "-40", "-60", "-10%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-1.256637rad", "-40", "-60", "-0.1"))

    assert.same_color({ "hsl", { 0, 0, 0 } }, csscolor4.hsl("0turn", "0", "0"))
    assert.same_color({ "hsl", { 0, 100, 100 } }, csscolor4.hsl("1turn", "100", "100"))
    assert.same_color({ "hsl", { 72, 40, 60 } }, csscolor4.hsl("0.2turn", "40", "60"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("0.2turn", "40", "60", "50%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("0.2turn", "40", "60", "0.5"))
    assert.same_color({ "hsl", { 72, 140, 160 }, 1 }, csscolor4.hsl("1.2turn", "140", "160", "120%"))
    assert.same_color({ "hsl", { 288, 0, -60 } }, csscolor4.hsl("-0.2turn", "-40", "-60"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-0.2turn", "-40", "-60", "-10%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-0.2turn", "-40", "-60", "-0.1"))

    assert.same_color({ "hsl", { 0, 0, 0 } }, csscolor4.hsl("0", "0%", "0%"))
    assert.same_color({ "hsl", { 0, 100, 100 } }, csscolor4.hsl("360", "100%", "100%"))
    assert.same_color({ "hsl", { 72, 40, 60 } }, csscolor4.hsl("72", "40%", "60%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("72", "40%", "60%", "50%"))
    assert.same_color({ "hsl", { 72, 40, 60 }, 0.5 }, csscolor4.hsl("72", "40%", "60%", "0.5"))
    assert.same_color({ "hsl", { 72, 140, 160 }, 1 }, csscolor4.hsl("432", "140%", "160%", "120%"))
    assert.same_color({ "hsl", { 288, 0, -60 } }, csscolor4.hsl("-72", "-40%", "-60%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-72", "-40%", "-60%", "-10%"))
    assert.same_color({ "hsl", { 288, 0, -60 }, 0 }, csscolor4.hsl("-72", "-40%", "-60%", "-0.1"))
  end)
end)

describe("hwb", function()
  it("parse hwb", function()
    assert.same_color(nil, csscolor4.hwb("", "", ""))

    assert.same_color({ "hwb", { "none", "none", "none" } }, csscolor4.hwb("none", "none", "none"))
    assert.same_color({ "hwb", { "none", "none", "none" }, "none" }, csscolor4.hwb("none", "none", "none", "none"))

    assert.same_color({ "hwb", { "none", "none", "none" } }, csscolor4.hwb("NONE", "NONE", "NONE"))
    assert.same_color({ "hwb", { "none", "none", "none" }, "none" }, csscolor4.hwb("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "hwb", { 0, 0, 0 } }, csscolor4.hwb("0", "0", "0"))
    assert.same_color({ "hwb", { 0, 100, 100 } }, csscolor4.hwb("360", "100", "100"))
    assert.same_color({ "hwb", { 72, 40, 60 } }, csscolor4.hwb("72", "40", "60"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("72", "40", "60", "50%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("72", "40", "60", "0.5"))
    assert.same_color({ "hwb", { 72, 140, 160 }, 1 }, csscolor4.hwb("432", "140", "160", "120%"))
    assert.same_color({ "hwb", { 288, -40, -60 } }, csscolor4.hwb("-72", "-40", "-60"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-72", "-40", "-60", "-10%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-72", "-40", "-60", "-0.1"))

    assert.same_color({ "hwb", { 0, 0, 0 } }, csscolor4.hwb("0deg", "0", "0"))
    assert.same_color({ "hwb", { 0, 100, 100 } }, csscolor4.hwb("360deg", "100", "100"))
    assert.same_color({ "hwb", { 72, 40, 60 } }, csscolor4.hwb("72deg", "40", "60"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("72deg", "40", "60", "50%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("72deg", "40", "60", "0.5"))
    assert.same_color({ "hwb", { 72, 140, 160 }, 1 }, csscolor4.hwb("432deg", "140", "160", "120%"))
    assert.same_color({ "hwb", { 288, -40, -60 } }, csscolor4.hwb("-72deg", "-40", "-60"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-72deg", "-40", "-60", "-10%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-72deg", "-40", "-60", "-0.1"))

    assert.same_color({ "hwb", { 0, 0, 0 } }, csscolor4.hwb("0grad", "0", "0"))
    assert.same_color({ "hwb", { 0, 100, 100 } }, csscolor4.hwb("400grad", "100", "100"))
    assert.same_color({ "hwb", { 72, 40, 60 } }, csscolor4.hwb("80grad", "40", "60"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("80grad", "40", "60", "50%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("80grad", "40", "60", "0.5"))
    assert.same_color({ "hwb", { 72, 140, 160 }, 1 }, csscolor4.hwb("480grad", "140", "160", "120%"))
    assert.same_color({ "hwb", { 288, -40, -60 } }, csscolor4.hwb("-80grad", "-40", "-60"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-80grad", "-40", "-60", "-10%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-80grad", "-40", "-60", "-0.1"))

    assert.same_color({ "hwb", { 0, 0, 0 } }, csscolor4.hwb("0rad", "0", "0"))
    assert.same_color({ "hwb", { 359.99998, 100, 100 } }, csscolor4.hwb("6.283185rad", "100", "100"))
    assert.same_color({ "hwb", { 72, 40, 60 } }, csscolor4.hwb("1.256637rad", "40", "60"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("1.256637rad", "40", "60", "50%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("1.256637rad", "40", "60", "0.5"))
    assert.same_color({ "hwb", { 72, 140, 160 }, 1 }, csscolor4.hwb("1.256637rad", "140", "160", "120%"))
    assert.same_color({ "hwb", { 288, -40, -60 } }, csscolor4.hwb("-1.256637rad", "-40", "-60"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-1.256637rad", "-40", "-60", "-10%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-1.256637rad", "-40", "-60", "-0.1"))

    assert.same_color({ "hwb", { 0, 0, 0 } }, csscolor4.hwb("0turn", "0", "0"))
    assert.same_color({ "hwb", { 0, 100, 100 } }, csscolor4.hwb("1turn", "100", "100"))
    assert.same_color({ "hwb", { 72, 40, 60 } }, csscolor4.hwb("0.2turn", "40", "60"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("0.2turn", "40", "60", "50%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("0.2turn", "40", "60", "0.5"))
    assert.same_color({ "hwb", { 72, 140, 160 }, 1 }, csscolor4.hwb("1.2turn", "140", "160", "120%"))
    assert.same_color({ "hwb", { 288, -40, -60 } }, csscolor4.hwb("-0.2turn", "-40", "-60"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-0.2turn", "-40", "-60", "-10%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-0.2turn", "-40", "-60", "-0.1"))

    assert.same_color({ "hwb", { 0, 0, 0 } }, csscolor4.hwb("0", "0%", "0%"))
    assert.same_color({ "hwb", { 0, 100, 100 } }, csscolor4.hwb("360", "100%", "100%"))
    assert.same_color({ "hwb", { 72, 40, 60 } }, csscolor4.hwb("72", "40%", "60%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("72", "40%", "60%", "50%"))
    assert.same_color({ "hwb", { 72, 40, 60 }, 0.5 }, csscolor4.hwb("72", "40%", "60%", "0.5"))
    assert.same_color({ "hwb", { 72, 140, 160 }, 1 }, csscolor4.hwb("432", "140%", "160%", "120%"))
    assert.same_color({ "hwb", { 288, -40, -60 } }, csscolor4.hwb("-72", "-40%", "-60%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-72", "-40%", "-60%", "-10%"))
    assert.same_color({ "hwb", { 288, -40, -60 }, 0 }, csscolor4.hwb("-72", "-40%", "-60%", "-0.1"))
  end)
end)

describe("lab", function()
  it("parse lab", function()
    assert.same_color(nil, csscolor4.lab("", "", ""))

    assert.same_color({ "lab", { "none", "none", "none" } }, csscolor4.lab("none", "none", "none"))
    assert.same_color({ "lab", { "none", "none", "none" }, "none" }, csscolor4.lab("none", "none", "none", "none"))

    assert.same_color({ "lab", { "none", "none", "none" } }, csscolor4.lab("NONE", "NONE", "NONE"))
    assert.same_color({ "lab", { "none", "none", "none" }, "none" }, csscolor4.lab("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "lab", { 0, 0, 0 } }, csscolor4.lab("0", "0", "0"))
    assert.same_color({ "lab", { 100, 125, 125 } }, csscolor4.lab("100", "125", "125"))
    assert.same_color({ "lab", { 100, -125, -125 } }, csscolor4.lab("100", "-125", "-125"))
    assert.same_color({ "lab", { 20, 50, 75 } }, csscolor4.lab("20", "50", "75"))
    assert.same_color({ "lab", { 20, 50, 75 }, 0.5 }, csscolor4.lab("20", "50", "75", "50%"))
    assert.same_color({ "lab", { 20, 50, 75 }, 0.5 }, csscolor4.lab("20", "50", "75", "0.5"))
    assert.same_color({ "lab", { 100, 175, 200 }, 1 }, csscolor4.lab("120", "175", "200", "120%"))
    assert.same_color({ "lab", { 0, -50, -75 } }, csscolor4.lab("-20", "-50", "-75"))
    assert.same_color({ "lab", { 0, -50, -75 }, 0 }, csscolor4.lab("-20", "-50", "-75", "-10%"))
    assert.same_color({ "lab", { 0, -50, -75 }, 0 }, csscolor4.lab("-20", "-50", "-75", "-0.1"))

    assert.same_color({ "lab", { 0, 0, 0 } }, csscolor4.lab("0%", "0%", "0%"))
    assert.same_color({ "lab", { 100, 125, 125 } }, csscolor4.lab("100%", "100%", "100%"))
    assert.same_color({ "lab", { 100, -125, -125 } }, csscolor4.lab("100%", "-100%", "-100%"))
    assert.same_color({ "lab", { 20, 50, 75 } }, csscolor4.lab("20%", "40%", "60%"))
    assert.same_color({ "lab", { 20, 50, 75 }, 0.5 }, csscolor4.lab("20%", "40%", "60%", "50%"))
    assert.same_color({ "lab", { 20, 50, 75 }, 0.5 }, csscolor4.lab("20%", "40%", "60%", "0.5"))
    assert.same_color({ "lab", { 100, 175, 200 }, 1 }, csscolor4.lab("120%", "140%", "160%", "120%"))
    assert.same_color({ "lab", { 0, -50, -75 } }, csscolor4.lab("-20%", "-40%", "-60%"))
    assert.same_color({ "lab", { 0, -50, -75 }, 0 }, csscolor4.lab("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "lab", { 0, -50, -75 }, 0 }, csscolor4.lab("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("lch", function()
  it("parse lch", function()
    assert.same_color(nil, csscolor4.lch("", "", ""))

    assert.same_color({ "lch", { "none", "none", "none" } }, csscolor4.lch("none", "none", "none"))
    assert.same_color({ "lch", { "none", "none", "none" }, "none" }, csscolor4.lch("none", "none", "none", "none"))

    assert.same_color({ "lch", { "none", "none", "none" } }, csscolor4.lch("NONE", "NONE", "NONE"))
    assert.same_color({ "lch", { "none", "none", "none" }, "none" }, csscolor4.lch("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "lch", { 0, 0, 0 } }, csscolor4.lch("0", "0", "0"))
    assert.same_color({ "lch", { 100, 150, 0 } }, csscolor4.lch("100", "150", "360"))
    assert.same_color({ "lch", { 40, 90, 72 } }, csscolor4.lch("40", "90", "72"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "72", "50%"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "72", "0.5"))
    assert.same_color({ "lch", { 100, 240, 72 }, 1 }, csscolor4.lch("140", "240", "432", "120%"))
    assert.same_color({ "lch", { 0, 0, 288 } }, csscolor4.lch("-40", "-90", "-72"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-72", "-10%"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-72", "-0.1"))

    assert.same_color({ "lch", { 0, 0, 0 } }, csscolor4.lch("0", "0", "0deg"))
    assert.same_color({ "lch", { 100, 150, 0 } }, csscolor4.lch("100", "150", "360deg"))
    assert.same_color({ "lch", { 40, 90, 72 } }, csscolor4.lch("40", "90", "72deg"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "72deg", "50%"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "72deg", "0.5"))
    assert.same_color({ "lch", { 100, 240, 72 }, 1 }, csscolor4.lch("140", "240", "432deg", "120%"))
    assert.same_color({ "lch", { 0, 0, 288 } }, csscolor4.lch("-40", "-90", "-72deg"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-72deg", "-10%"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-72deg", "-0.1"))

    assert.same_color({ "lch", { 0, 0, 0 } }, csscolor4.lch("0", "0", "0grad"))
    assert.same_color({ "lch", { 100, 150, 0 } }, csscolor4.lch("100", "150", "400grad"))
    assert.same_color({ "lch", { 40, 90, 72 } }, csscolor4.lch("40", "90", "80grad"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "80grad", "50%"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "80grad", "0.5"))
    assert.same_color({ "lch", { 100, 240, 72 }, 1 }, csscolor4.lch("140", "240", "480grad", "120%"))
    assert.same_color({ "lch", { 0, 0, 288 } }, csscolor4.lch("-40", "-90", "-80grad"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-80grad", "-10%"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-80grad", "-0.1"))

    assert.same_color({ "lch", { 0, 0, 0 } }, csscolor4.lch("0", "0", "0rad"))
    assert.same_color({ "lch", { 100, 150, 359.99998 } }, csscolor4.lch("100", "150", "6.283185rad"))
    assert.same_color({ "lch", { 40, 90, 72 } }, csscolor4.lch("40", "90", "1.256637rad"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "1.256637rad", "50%"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "1.256637rad", "0.5"))
    assert.same_color({ "lch", { 100, 240, 72 }, 1 }, csscolor4.lch("140", "240", "1.256637rad", "120%"))
    assert.same_color({ "lch", { 0, 0, 288 } }, csscolor4.lch("-40", "-90", "-1.256637rad"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-1.256637rad", "-10%"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-1.256637rad", "-0.1"))

    assert.same_color({ "lch", { 0, 0, 0 } }, csscolor4.lch("0", "0", "0turn"))
    assert.same_color({ "lch", { 100, 150, 0 } }, csscolor4.lch("100", "150", "1turn"))
    assert.same_color({ "lch", { 40, 90, 72 } }, csscolor4.lch("40", "90", "0.2turn"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "0.2turn", "50%"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40", "90", "0.2turn", "0.5"))
    assert.same_color({ "lch", { 100, 240, 72 }, 1 }, csscolor4.lch("140", "240", "0.2turn", "120%"))
    assert.same_color({ "lch", { 0, 0, 288 } }, csscolor4.lch("-40", "-90", "-0.2turn"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-0.2turn", "-10%"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40", "-90", "-0.2turn", "-0.1"))

    assert.same_color({ "lch", { 0, 0, 0 } }, csscolor4.lch("0%", "0%", "0"))
    assert.same_color({ "lch", { 100, 150, 0 } }, csscolor4.lch("100%", "100%", "360"))
    assert.same_color({ "lch", { 40, 90, 72 } }, csscolor4.lch("40%", "60%", "72"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40%", "60%", "72", "50%"))
    assert.same_color({ "lch", { 40, 90, 72 }, 0.5 }, csscolor4.lch("40%", "60%", "72", "0.5"))
    assert.same_color({ "lch", { 100, 240, 72 }, 1 }, csscolor4.lch("140%", "160%", "432", "120%"))
    assert.same_color({ "lch", { 0, 0, 288 } }, csscolor4.lch("-40%", "-60%", "-72"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40%", "-60%", "-72", "-10%"))
    assert.same_color({ "lch", { 0, 0, 288 }, 0 }, csscolor4.lch("-40%", "-60%", "-72", "-0.1"))
  end)
end)
