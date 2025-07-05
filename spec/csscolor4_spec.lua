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
  local tolerance = arguments[3] or 0.00001

  if expected_color == nil then
    assert(actual_color == nil, "expected == nil but actual ~= nil", level)
    return true
  end

  assert(actual_color ~= nil, "expected ~= nil but actual == nil", level)

  -- colorspace must equal.
  assert(expected_color[1] == actual_color[1], string.format("%s ~= %s", expected_color[1], actual_color[1]), level)

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
    assert.same_color({ "hsl", { 71.99998, 140, 160 }, 1 }, csscolor4.hsl("7.539822rad", "140", "160", "120%"))
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
    assert.same_color({ "hwb", { 71.99998, 140, 160 }, 1 }, csscolor4.hwb("7.539822rad", "140", "160", "120%"))
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
    assert.same_color({ "lch", { 100, 240, 71.99998 }, 1 }, csscolor4.lch("140", "240", "7.539822rad", "120%"))
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

describe("oklab", function()
  it("parse oklab", function()
    assert.same_color(nil, csscolor4.oklab("", "", ""))

    assert.same_color({ "oklab", { "none", "none", "none" } }, csscolor4.oklab("none", "none", "none"))
    assert.same_color({ "oklab", { "none", "none", "none" }, "none" }, csscolor4.oklab("none", "none", "none", "none"))

    assert.same_color({ "oklab", { "none", "none", "none" } }, csscolor4.oklab("NONE", "NONE", "NONE"))
    assert.same_color({ "oklab", { "none", "none", "none" }, "none" }, csscolor4.oklab("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "oklab", { 0, 0, 0 } }, csscolor4.oklab("0", "0", "0"))
    assert.same_color({ "oklab", { 1, 0.4, 0.4 } }, csscolor4.oklab("1", "0.4", "0.4"))
    assert.same_color({ "oklab", { 1, -0.4, -0.4 } }, csscolor4.oklab("1", "-0.4", "-0.4"))
    assert.same_color({ "oklab", { 0.2, 0.16, 0.24 } }, csscolor4.oklab("0.2", "0.16", "0.24"))
    assert.same_color({ "oklab", { 0.2, 0.16, 0.24 }, 0.5 }, csscolor4.oklab("0.2", "0.16", "0.24", "50%"))
    assert.same_color({ "oklab", { 0.2, 0.16, 0.24 }, 0.5 }, csscolor4.oklab("0.2", "0.16", "0.24", "0.5"))
    assert.same_color({ "oklab", { 1, 0.56, 0.64 }, 1 }, csscolor4.oklab("1.2", "0.56", "0.64", "120%"))
    assert.same_color({ "oklab", { 0, -0.16, -0.24 } }, csscolor4.oklab("-0.2", "-0.16", "-0.24"))
    assert.same_color({ "oklab", { 0, -0.16, -0.24 }, 0 }, csscolor4.oklab("-0.2", "-0.16", "-0.24", "-10%"))
    assert.same_color({ "oklab", { 0, -0.16, -0.24 }, 0 }, csscolor4.oklab("-0.2", "-0.16", "-0.24", "-0.1"))

    assert.same_color({ "oklab", { 0, 0, 0 } }, csscolor4.oklab("0%", "0%", "0%"))
    assert.same_color({ "oklab", { 1, 0.4, 0.4 } }, csscolor4.oklab("100%", "100%", "100%"))
    assert.same_color({ "oklab", { 1, -0.4, -0.4 } }, csscolor4.oklab("100%", "-100%", "-100%"))
    assert.same_color({ "oklab", { 0.2, 0.16, 0.24 } }, csscolor4.oklab("20%", "40%", "60%"))
    assert.same_color({ "oklab", { 0.2, 0.16, 0.24 }, 0.5 }, csscolor4.oklab("20%", "40%", "60%", "50%"))
    assert.same_color({ "oklab", { 0.2, 0.16, 0.24 }, 0.5 }, csscolor4.oklab("20%", "40%", "60%", "0.5"))
    assert.same_color({ "oklab", { 1, 0.56, 0.64 }, 1 }, csscolor4.oklab("120%", "140%", "160%", "120%"))
    assert.same_color({ "oklab", { 0, -0.16, -0.24 } }, csscolor4.oklab("-20%", "-40%", "-60%"))
    assert.same_color({ "oklab", { 0, -0.16, -0.24 }, 0 }, csscolor4.oklab("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "oklab", { 0, -0.16, -0.24 }, 0 }, csscolor4.oklab("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("oklch", function()
  it("parse oklch", function()
    assert.same_color(nil, csscolor4.oklch("", "", ""))

    assert.same_color({ "oklch", { "none", "none", "none" } }, csscolor4.oklch("none", "none", "none"))
    assert.same_color({ "oklch", { "none", "none", "none" }, "none" }, csscolor4.oklch("none", "none", "none", "none"))

    assert.same_color({ "oklch", { "none", "none", "none" } }, csscolor4.oklch("NONE", "NONE", "NONE"))
    assert.same_color({ "oklch", { "none", "none", "none" }, "none" }, csscolor4.oklch("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "oklch", { 0, 0, 0 } }, csscolor4.oklch("0", "0", "0"))
    assert.same_color({ "oklch", { 1, 0.4, 0 } }, csscolor4.oklch("1", "0.4", "360"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 } }, csscolor4.oklch("0.4", "0.24", "72"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "72", "50%"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "72", "0.5"))
    assert.same_color({ "oklch", { 1, 0.64, 72 }, 1 }, csscolor4.oklch("1.4", "0.64", "432", "120%"))
    assert.same_color({ "oklch", { 0, 0, 288 } }, csscolor4.oklch("-0.4", "-0.24", "-72"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-72", "-10%"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-72", "-0.1"))

    assert.same_color({ "oklch", { 0, 0, 0 } }, csscolor4.oklch("0", "0", "0deg"))
    assert.same_color({ "oklch", { 1, 0.4, 0 } }, csscolor4.oklch("1", "0.4", "360deg"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 } }, csscolor4.oklch("0.4", "0.24", "72deg"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "72deg", "50%"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "72deg", "0.5"))
    assert.same_color({ "oklch", { 1, 0.64, 72 }, 1 }, csscolor4.oklch("1.4", "0.64", "432deg", "120%"))
    assert.same_color({ "oklch", { 0, 0, 288 } }, csscolor4.oklch("-0.4", "-0.24", "-72deg"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-72deg", "-10%"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-72deg", "-0.1"))

    assert.same_color({ "oklch", { 0, 0, 0 } }, csscolor4.oklch("0", "0", "0grad"))
    assert.same_color({ "oklch", { 1, 0.4, 0 } }, csscolor4.oklch("1", "0.4", "400grad"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 } }, csscolor4.oklch("0.4", "0.24", "80grad"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "80grad", "50%"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "80grad", "0.5"))
    assert.same_color({ "oklch", { 1, 0.64, 72 }, 1 }, csscolor4.oklch("1.4", "0.64", "480grad", "120%"))
    assert.same_color({ "oklch", { 0, 0, 288 } }, csscolor4.oklch("-0.4", "-0.24", "-80grad"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-80grad", "-10%"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-80grad", "-0.1"))

    assert.same_color({ "oklch", { 0, 0, 0 } }, csscolor4.oklch("0", "0", "0rad"))
    assert.same_color({ "oklch", { 1, 0.4, 359.99998 } }, csscolor4.oklch("1", "0.4", "6.283185rad"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 } }, csscolor4.oklch("0.4", "0.24", "1.256637rad"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "1.256637rad", "50%"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "1.256637rad", "0.5"))
    assert.same_color({ "oklch", { 1, 0.64, 71.99998 }, 1 }, csscolor4.oklch("1.4", "0.64", "7.539822rad", "120%"))
    assert.same_color({ "oklch", { 0, 0, 288 } }, csscolor4.oklch("-0.4", "-0.24", "-1.256637rad"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-1.256637rad", "-10%"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-1.256637rad", "-0.1"))

    assert.same_color({ "oklch", { 0, 0, 0 } }, csscolor4.oklch("0", "0", "0turn"))
    assert.same_color({ "oklch", { 1, 0.4, 0 } }, csscolor4.oklch("1", "0.4", "1turn"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 } }, csscolor4.oklch("0.4", "0.24", "0.2turn"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "0.2turn", "50%"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("0.4", "0.24", "0.2turn", "0.5"))
    assert.same_color({ "oklch", { 1, 0.64, 72 }, 1 }, csscolor4.oklch("1.4", "0.64", "1.2turn", "120%"))
    assert.same_color({ "oklch", { 0, 0, 288 } }, csscolor4.oklch("-0.4", "-0.24", "-0.2turn"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-0.2turn", "-10%"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-0.4", "-0.24", "-0.2turn", "-0.1"))

    assert.same_color({ "oklch", { 0, 0, 0 } }, csscolor4.oklch("0%", "0%", "0"))
    assert.same_color({ "oklch", { 1, 0.4, 0 } }, csscolor4.oklch("100%", "100%", "360"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 } }, csscolor4.oklch("40%", "60%", "72"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("40%", "60%", "72", "50%"))
    assert.same_color({ "oklch", { 0.4, 0.24, 72 }, 0.5 }, csscolor4.oklch("40%", "60%", "72", "0.5"))
    assert.same_color({ "oklch", { 1, 0.64, 72 }, 1 }, csscolor4.oklch("140%", "160%", "432", "120%"))
    assert.same_color({ "oklch", { 0, 0, 288 } }, csscolor4.oklch("-40%", "-60%", "-72"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-40%", "-60%", "-72", "-10%"))
    assert.same_color({ "oklch", { 0, 0, 288 }, 0 }, csscolor4.oklch("-40%", "-60%", "-72", "-0.1"))
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

describe("srgb_linear", function()
  it("parse srgb_linear", function()
    assert.same_color(nil, csscolor4.srgb_linear("", "", ""))

    assert.same_color({ "srgb-linear", { "none", "none", "none" } }, csscolor4.srgb_linear("none", "none", "none"))
    assert.same_color(
      { "srgb-linear", { "none", "none", "none" }, "none" },
      csscolor4.srgb_linear("none", "none", "none", "none")
    )

    assert.same_color({ "srgb-linear", { "none", "none", "none" } }, csscolor4.srgb_linear("NONE", "NONE", "NONE"))
    assert.same_color(
      { "srgb-linear", { "none", "none", "none" }, "none" },
      csscolor4.srgb_linear("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "srgb-linear", { 0, 0, 0 } }, csscolor4.srgb_linear("0", "0", "0"))
    assert.same_color({ "srgb-linear", { 1, 1, 1 } }, csscolor4.srgb_linear("1", "1", "1"))
    assert.same_color({ "srgb-linear", { 0.2, 0.4, 0.6 } }, csscolor4.srgb_linear("0.2", "0.4", "0.6"))
    assert.same_color({ "srgb-linear", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb_linear("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "srgb-linear", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb_linear("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "srgb-linear", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.srgb_linear("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "srgb-linear", { -0.2, -0.4, -0.6 } }, csscolor4.srgb_linear("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "srgb-linear", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb_linear("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "srgb-linear", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb_linear("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "srgb-linear", { 0, 0, 0 } }, csscolor4.srgb_linear("0%", "0%", "0%"))
    assert.same_color({ "srgb-linear", { 1, 1, 1 } }, csscolor4.srgb_linear("100%", "100%", "100%"))
    assert.same_color({ "srgb-linear", { 0.2, 0.4, 0.6 } }, csscolor4.srgb_linear("20%", "40%", "60%"))
    assert.same_color({ "srgb-linear", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb_linear("20%", "40%", "60%", "50%"))
    assert.same_color({ "srgb-linear", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.srgb_linear("20%", "40%", "60%", "0.5"))
    assert.same_color({ "srgb-linear", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.srgb_linear("120%", "140%", "160%", "120%"))
    assert.same_color({ "srgb-linear", { -0.2, -0.4, -0.6 } }, csscolor4.srgb_linear("-20%", "-40%", "-60%"))
    assert.same_color({ "srgb-linear", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb_linear("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "srgb-linear", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.srgb_linear("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("display_p3", function()
  it("parse display_p3", function()
    assert.same_color(nil, csscolor4.display_p3("", "", ""))

    assert.same_color({ "display-p3", { "none", "none", "none" } }, csscolor4.display_p3("none", "none", "none"))
    assert.same_color(
      { "display-p3", { "none", "none", "none" }, "none" },
      csscolor4.display_p3("none", "none", "none", "none")
    )

    assert.same_color({ "display-p3", { "none", "none", "none" } }, csscolor4.display_p3("NONE", "NONE", "NONE"))
    assert.same_color(
      { "display-p3", { "none", "none", "none" }, "none" },
      csscolor4.display_p3("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "display-p3", { 0, 0, 0 } }, csscolor4.display_p3("0", "0", "0"))
    assert.same_color({ "display-p3", { 1, 1, 1 } }, csscolor4.display_p3("1", "1", "1"))
    assert.same_color({ "display-p3", { 0.2, 0.4, 0.6 } }, csscolor4.display_p3("0.2", "0.4", "0.6"))
    assert.same_color({ "display-p3", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.display_p3("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "display-p3", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.display_p3("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "display-p3", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.display_p3("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "display-p3", { -0.2, -0.4, -0.6 } }, csscolor4.display_p3("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "display-p3", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.display_p3("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "display-p3", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.display_p3("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "display-p3", { 0, 0, 0 } }, csscolor4.display_p3("0%", "0%", "0%"))
    assert.same_color({ "display-p3", { 1, 1, 1 } }, csscolor4.display_p3("100%", "100%", "100%"))
    assert.same_color({ "display-p3", { 0.2, 0.4, 0.6 } }, csscolor4.display_p3("20%", "40%", "60%"))
    assert.same_color({ "display-p3", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.display_p3("20%", "40%", "60%", "50%"))
    assert.same_color({ "display-p3", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.display_p3("20%", "40%", "60%", "0.5"))
    assert.same_color({ "display-p3", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.display_p3("120%", "140%", "160%", "120%"))
    assert.same_color({ "display-p3", { -0.2, -0.4, -0.6 } }, csscolor4.display_p3("-20%", "-40%", "-60%"))
    assert.same_color({ "display-p3", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.display_p3("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "display-p3", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.display_p3("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("a98_rgb", function()
  it("parse a98_rgb", function()
    assert.same_color(nil, csscolor4.a98_rgb("", "", ""))

    assert.same_color({ "a98-rgb", { "none", "none", "none" } }, csscolor4.a98_rgb("none", "none", "none"))
    assert.same_color(
      { "a98-rgb", { "none", "none", "none" }, "none" },
      csscolor4.a98_rgb("none", "none", "none", "none")
    )

    assert.same_color({ "a98-rgb", { "none", "none", "none" } }, csscolor4.a98_rgb("NONE", "NONE", "NONE"))
    assert.same_color(
      { "a98-rgb", { "none", "none", "none" }, "none" },
      csscolor4.a98_rgb("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "a98-rgb", { 0, 0, 0 } }, csscolor4.a98_rgb("0", "0", "0"))
    assert.same_color({ "a98-rgb", { 1, 1, 1 } }, csscolor4.a98_rgb("1", "1", "1"))
    assert.same_color({ "a98-rgb", { 0.2, 0.4, 0.6 } }, csscolor4.a98_rgb("0.2", "0.4", "0.6"))
    assert.same_color({ "a98-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.a98_rgb("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "a98-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.a98_rgb("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "a98-rgb", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.a98_rgb("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "a98-rgb", { -0.2, -0.4, -0.6 } }, csscolor4.a98_rgb("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "a98-rgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.a98_rgb("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "a98-rgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.a98_rgb("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "a98-rgb", { 0, 0, 0 } }, csscolor4.a98_rgb("0%", "0%", "0%"))
    assert.same_color({ "a98-rgb", { 1, 1, 1 } }, csscolor4.a98_rgb("100%", "100%", "100%"))
    assert.same_color({ "a98-rgb", { 0.2, 0.4, 0.6 } }, csscolor4.a98_rgb("20%", "40%", "60%"))
    assert.same_color({ "a98-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.a98_rgb("20%", "40%", "60%", "50%"))
    assert.same_color({ "a98-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.a98_rgb("20%", "40%", "60%", "0.5"))
    assert.same_color({ "a98-rgb", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.a98_rgb("120%", "140%", "160%", "120%"))
    assert.same_color({ "a98-rgb", { -0.2, -0.4, -0.6 } }, csscolor4.a98_rgb("-20%", "-40%", "-60%"))
    assert.same_color({ "a98-rgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.a98_rgb("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "a98-rgb", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.a98_rgb("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("prophoto_rgb", function()
  it("parse prophoto_rgb", function()
    assert.same_color(nil, csscolor4.prophoto_rgb("", "", ""))

    assert.same_color({ "prophoto-rgb", { "none", "none", "none" } }, csscolor4.prophoto_rgb("none", "none", "none"))
    assert.same_color(
      { "prophoto-rgb", { "none", "none", "none" }, "none" },
      csscolor4.prophoto_rgb("none", "none", "none", "none")
    )

    assert.same_color({ "prophoto-rgb", { "none", "none", "none" } }, csscolor4.prophoto_rgb("NONE", "NONE", "NONE"))
    assert.same_color(
      { "prophoto-rgb", { "none", "none", "none" }, "none" },
      csscolor4.prophoto_rgb("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "prophoto-rgb", { 0, 0, 0 } }, csscolor4.prophoto_rgb("0", "0", "0"))
    assert.same_color({ "prophoto-rgb", { 1, 1, 1 } }, csscolor4.prophoto_rgb("1", "1", "1"))
    assert.same_color({ "prophoto-rgb", { 0.2, 0.4, 0.6 } }, csscolor4.prophoto_rgb("0.2", "0.4", "0.6"))
    assert.same_color({ "prophoto-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.prophoto_rgb("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "prophoto-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.prophoto_rgb("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "prophoto-rgb", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.prophoto_rgb("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "prophoto-rgb", { -0.2, -0.4, -0.6 } }, csscolor4.prophoto_rgb("-0.2", "-0.4", "-0.6"))
    assert.same_color(
      { "prophoto-rgb", { -0.2, -0.4, -0.6 }, 0 },
      csscolor4.prophoto_rgb("-0.2", "-0.4", "-0.6", "-10%")
    )
    assert.same_color(
      { "prophoto-rgb", { -0.2, -0.4, -0.6 }, 0 },
      csscolor4.prophoto_rgb("-0.2", "-0.4", "-0.6", "-0.1")
    )

    assert.same_color({ "prophoto-rgb", { 0, 0, 0 } }, csscolor4.prophoto_rgb("0%", "0%", "0%"))
    assert.same_color({ "prophoto-rgb", { 1, 1, 1 } }, csscolor4.prophoto_rgb("100%", "100%", "100%"))
    assert.same_color({ "prophoto-rgb", { 0.2, 0.4, 0.6 } }, csscolor4.prophoto_rgb("20%", "40%", "60%"))
    assert.same_color({ "prophoto-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.prophoto_rgb("20%", "40%", "60%", "50%"))
    assert.same_color({ "prophoto-rgb", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.prophoto_rgb("20%", "40%", "60%", "0.5"))
    assert.same_color({ "prophoto-rgb", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.prophoto_rgb("120%", "140%", "160%", "120%"))
    assert.same_color({ "prophoto-rgb", { -0.2, -0.4, -0.6 } }, csscolor4.prophoto_rgb("-20%", "-40%", "-60%"))
    assert.same_color(
      { "prophoto-rgb", { -0.2, -0.4, -0.6 }, 0 },
      csscolor4.prophoto_rgb("-20%", "-40%", "-60%", "-10%")
    )
    assert.same_color(
      { "prophoto-rgb", { -0.2, -0.4, -0.6 }, 0 },
      csscolor4.prophoto_rgb("-20%", "-40%", "-60%", "-0.1")
    )
  end)
end)

describe("rec2020", function()
  it("parse rec2020", function()
    assert.same_color(nil, csscolor4.rec2020("", "", ""))

    assert.same_color({ "rec2020", { "none", "none", "none" } }, csscolor4.rec2020("none", "none", "none"))
    assert.same_color(
      { "rec2020", { "none", "none", "none" }, "none" },
      csscolor4.rec2020("none", "none", "none", "none")
    )

    assert.same_color({ "rec2020", { "none", "none", "none" } }, csscolor4.rec2020("NONE", "NONE", "NONE"))
    assert.same_color(
      { "rec2020", { "none", "none", "none" }, "none" },
      csscolor4.rec2020("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "rec2020", { 0, 0, 0 } }, csscolor4.rec2020("0", "0", "0"))
    assert.same_color({ "rec2020", { 1, 1, 1 } }, csscolor4.rec2020("1", "1", "1"))
    assert.same_color({ "rec2020", { 0.2, 0.4, 0.6 } }, csscolor4.rec2020("0.2", "0.4", "0.6"))
    assert.same_color({ "rec2020", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.rec2020("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "rec2020", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.rec2020("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "rec2020", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.rec2020("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "rec2020", { -0.2, -0.4, -0.6 } }, csscolor4.rec2020("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "rec2020", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.rec2020("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "rec2020", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.rec2020("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "rec2020", { 0, 0, 0 } }, csscolor4.rec2020("0%", "0%", "0%"))
    assert.same_color({ "rec2020", { 1, 1, 1 } }, csscolor4.rec2020("100%", "100%", "100%"))
    assert.same_color({ "rec2020", { 0.2, 0.4, 0.6 } }, csscolor4.rec2020("20%", "40%", "60%"))
    assert.same_color({ "rec2020", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.rec2020("20%", "40%", "60%", "50%"))
    assert.same_color({ "rec2020", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.rec2020("20%", "40%", "60%", "0.5"))
    assert.same_color({ "rec2020", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.rec2020("120%", "140%", "160%", "120%"))
    assert.same_color({ "rec2020", { -0.2, -0.4, -0.6 } }, csscolor4.rec2020("-20%", "-40%", "-60%"))
    assert.same_color({ "rec2020", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.rec2020("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "rec2020", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.rec2020("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("xyz", function()
  it("parse xyz", function()
    assert.same_color(nil, csscolor4.xyz("", "", ""))

    assert.same_color({ "xyz", { "none", "none", "none" } }, csscolor4.xyz("none", "none", "none"))
    assert.same_color({ "xyz", { "none", "none", "none" }, "none" }, csscolor4.xyz("none", "none", "none", "none"))

    assert.same_color({ "xyz", { "none", "none", "none" } }, csscolor4.xyz("NONE", "NONE", "NONE"))
    assert.same_color({ "xyz", { "none", "none", "none" }, "none" }, csscolor4.xyz("NONE", "NONE", "NONE", "NONE"))

    assert.same_color({ "xyz", { 0, 0, 0 } }, csscolor4.xyz("0", "0", "0"))
    assert.same_color({ "xyz", { 1, 1, 1 } }, csscolor4.xyz("1", "1", "1"))
    assert.same_color({ "xyz", { 0.2, 0.4, 0.6 } }, csscolor4.xyz("0.2", "0.4", "0.6"))
    assert.same_color({ "xyz", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "xyz", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "xyz", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.xyz("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "xyz", { -0.2, -0.4, -0.6 } }, csscolor4.xyz("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "xyz", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "xyz", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "xyz", { 0, 0, 0 } }, csscolor4.xyz("0%", "0%", "0%"))
    assert.same_color({ "xyz", { 1, 1, 1 } }, csscolor4.xyz("100%", "100%", "100%"))
    assert.same_color({ "xyz", { 0.2, 0.4, 0.6 } }, csscolor4.xyz("20%", "40%", "60%"))
    assert.same_color({ "xyz", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz("20%", "40%", "60%", "50%"))
    assert.same_color({ "xyz", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz("20%", "40%", "60%", "0.5"))
    assert.same_color({ "xyz", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.xyz("120%", "140%", "160%", "120%"))
    assert.same_color({ "xyz", { -0.2, -0.4, -0.6 } }, csscolor4.xyz("-20%", "-40%", "-60%"))
    assert.same_color({ "xyz", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "xyz", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("xyz_d50", function()
  it("parse xyz_d50", function()
    assert.same_color(nil, csscolor4.xyz_d50("", "", ""))

    assert.same_color({ "xyz-d50", { "none", "none", "none" } }, csscolor4.xyz_d50("none", "none", "none"))
    assert.same_color(
      { "xyz-d50", { "none", "none", "none" }, "none" },
      csscolor4.xyz_d50("none", "none", "none", "none")
    )

    assert.same_color({ "xyz-d50", { "none", "none", "none" } }, csscolor4.xyz_d50("NONE", "NONE", "NONE"))
    assert.same_color(
      { "xyz-d50", { "none", "none", "none" }, "none" },
      csscolor4.xyz_d50("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "xyz-d50", { 0, 0, 0 } }, csscolor4.xyz_d50("0", "0", "0"))
    assert.same_color({ "xyz-d50", { 1, 1, 1 } }, csscolor4.xyz_d50("1", "1", "1"))
    assert.same_color({ "xyz-d50", { 0.2, 0.4, 0.6 } }, csscolor4.xyz_d50("0.2", "0.4", "0.6"))
    assert.same_color({ "xyz-d50", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d50("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "xyz-d50", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d50("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "xyz-d50", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.xyz_d50("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "xyz-d50", { -0.2, -0.4, -0.6 } }, csscolor4.xyz_d50("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "xyz-d50", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d50("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "xyz-d50", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d50("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "xyz-d50", { 0, 0, 0 } }, csscolor4.xyz_d50("0%", "0%", "0%"))
    assert.same_color({ "xyz-d50", { 1, 1, 1 } }, csscolor4.xyz_d50("100%", "100%", "100%"))
    assert.same_color({ "xyz-d50", { 0.2, 0.4, 0.6 } }, csscolor4.xyz_d50("20%", "40%", "60%"))
    assert.same_color({ "xyz-d50", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d50("20%", "40%", "60%", "50%"))
    assert.same_color({ "xyz-d50", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d50("20%", "40%", "60%", "0.5"))
    assert.same_color({ "xyz-d50", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.xyz_d50("120%", "140%", "160%", "120%"))
    assert.same_color({ "xyz-d50", { -0.2, -0.4, -0.6 } }, csscolor4.xyz_d50("-20%", "-40%", "-60%"))
    assert.same_color({ "xyz-d50", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d50("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "xyz-d50", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d50("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("xyz_d65", function()
  it("parse xyz_d65", function()
    assert.same_color(nil, csscolor4.xyz_d65("", "", ""))

    assert.same_color({ "xyz-d65", { "none", "none", "none" } }, csscolor4.xyz_d65("none", "none", "none"))
    assert.same_color(
      { "xyz-d65", { "none", "none", "none" }, "none" },
      csscolor4.xyz_d65("none", "none", "none", "none")
    )

    assert.same_color({ "xyz-d65", { "none", "none", "none" } }, csscolor4.xyz_d65("NONE", "NONE", "NONE"))
    assert.same_color(
      { "xyz-d65", { "none", "none", "none" }, "none" },
      csscolor4.xyz_d65("NONE", "NONE", "NONE", "NONE")
    )

    assert.same_color({ "xyz-d65", { 0, 0, 0 } }, csscolor4.xyz_d65("0", "0", "0"))
    assert.same_color({ "xyz-d65", { 1, 1, 1 } }, csscolor4.xyz_d65("1", "1", "1"))
    assert.same_color({ "xyz-d65", { 0.2, 0.4, 0.6 } }, csscolor4.xyz_d65("0.2", "0.4", "0.6"))
    assert.same_color({ "xyz-d65", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d65("0.2", "0.4", "0.6", "50%"))
    assert.same_color({ "xyz-d65", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d65("0.2", "0.4", "0.6", "0.5"))
    assert.same_color({ "xyz-d65", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.xyz_d65("1.2", "1.4", "1.6", "120%"))
    assert.same_color({ "xyz-d65", { -0.2, -0.4, -0.6 } }, csscolor4.xyz_d65("-0.2", "-0.4", "-0.6"))
    assert.same_color({ "xyz-d65", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d65("-0.2", "-0.4", "-0.6", "-10%"))
    assert.same_color({ "xyz-d65", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d65("-0.2", "-0.4", "-0.6", "-0.1"))

    assert.same_color({ "xyz-d65", { 0, 0, 0 } }, csscolor4.xyz_d65("0%", "0%", "0%"))
    assert.same_color({ "xyz-d65", { 1, 1, 1 } }, csscolor4.xyz_d65("100%", "100%", "100%"))
    assert.same_color({ "xyz-d65", { 0.2, 0.4, 0.6 } }, csscolor4.xyz_d65("20%", "40%", "60%"))
    assert.same_color({ "xyz-d65", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d65("20%", "40%", "60%", "50%"))
    assert.same_color({ "xyz-d65", { 0.2, 0.4, 0.6 }, 0.5 }, csscolor4.xyz_d65("20%", "40%", "60%", "0.5"))
    assert.same_color({ "xyz-d65", { 1.2, 1.4, 1.6 }, 1 }, csscolor4.xyz_d65("120%", "140%", "160%", "120%"))
    assert.same_color({ "xyz-d65", { -0.2, -0.4, -0.6 } }, csscolor4.xyz_d65("-20%", "-40%", "-60%"))
    assert.same_color({ "xyz-d65", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d65("-20%", "-40%", "-60%", "-10%"))
    assert.same_color({ "xyz-d65", { -0.2, -0.4, -0.6 }, 0 }, csscolor4.xyz_d65("-20%", "-40%", "-60%", "-0.1"))
  end)
end)

describe("Conversion between rgb and srgb", function()
  it("convert rgb to srgb", function()
    assert.same_color(
      { "srgb", { "none", "none", "none" }, "none" },
      csscolor4.rgb2srgb({ "rgb", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-xyz
    -- EXAMPLE 30
    assert.same_color(
      { "srgb", { 0.4627, 0.3294, 0.8039 }, 0.5 },
      csscolor4.rgb2srgb({ "rgb", { 118, 84, 205 }, 0.5 }),
      0.0001
    )
  end)
  it("convert srgb to rgb", function()
    assert.same_color(
      { "rgb", { "none", "none", "none" }, "none" },
      csscolor4.srgb2rgb({ "srgb", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-xyz
    -- EXAMPLE 30
    assert.same_color(
      { "rgb", { 118, 84, 205 }, 0.5 },
      csscolor4.srgb2rgb({ "srgb", { 0.4627, 0.3294, 0.8039 }, 0.5 }),
      0.1
    )
  end)
end)

describe("Conversion between hsl and srgb", function()
  it("convert hsl to srgb", function()
    assert.same_color(
      { "srgb", { 0, 0, 0 }, "none" },
      csscolor4.hsl2srgb({ "hsl", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-hwb-simple
    -- EXAMPLE 21
    assert.same_color(
      { "srgb", { 0.2, 0.9, 0.55 }, 0.5 },
      csscolor4.hsl2srgb({ "hsl", { 150, 77.78, 55 }, 0.5 }),
      0.0001
    )
  end)
  it("convert srgb to hsl", function()
    assert.same_color(
      { "hsl", { "none", 0, 0 }, "none" },
      csscolor4.srgb2hsl({ "srgb", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-hwb-simple
    -- EXAMPLE 21
    assert.same_color({ "hsl", { 150, 77.78, 55 }, 0.5 }, csscolor4.srgb2hsl({ "srgb", { 0.2, 0.9, 0.55 }, 0.5 }), 0.01)
  end)
end)

describe("Conversion between hwb and srgb", function()
  it("convert hwb to srgb", function()
    assert.same_color(
      { "srgb", { 1, 0, 0 }, "none" },
      csscolor4.hwb2srgb({ "hwb", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-hwb-simple
    -- EXAMPLE 21
    assert.same_color({ "srgb", { 0.2, 0.9, 0.55 }, 0.5 }, csscolor4.hwb2srgb({ "hwb", { 150, 20, 10 }, 0.5 }))
  end)
  it("convert srgb to hwb", function()
    assert.same_color(
      { "hwb", { "none", 0, 100 }, "none" },
      csscolor4.srgb2hwb({ "srgb", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-hwb-simple
    -- EXAMPLE 21
    assert.same_color({ "hwb", { 150, 20, 10 }, 0.5 }, csscolor4.srgb2hwb({ "srgb", { 0.2, 0.9, 0.55 }, 0.5 }))
  end)
end)

describe("Conversion between lab and lch", function()
  it("convert lab to lch", function()
    assert.same_color(
      { "lch", { "none", 0, 0 }, "none" },
      csscolor4.lab2lch({ "lab", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-lab-samples
    --EXAMPLE 23
    --EXAMPLE 24
    assert.same_color(
      { "lch", { 29.2345, 44.2, 27 }, 0.5 },
      csscolor4.lab2lch({ "lab", { 29.2345, 39.3825, 20.0664 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      { "lch", { 52.2345, 72.2, 56.2 }, 0.5 },
      csscolor4.lab2lch({ "lab", { 52.2345, 40.1645, 59.9971 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      { "lch", { 60.2345, 59.2, 95.2 }, 0.5 },
      csscolor4.lab2lch({ "lab", { 60.2345, -5.3654, 58.9971 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "lch", { 62.2345, 59.2, 126.2 }, 0.5 },
      csscolor4.lab2lch({ "lab", { 62.2345, -34.9638, 47.7721 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      { "lch", { 67.5345, 42.5, 258.2 }, 0.5 },
      csscolor4.lab2lch({ "lab", { 67.5345, -8.6911, -41.6019 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      -- The example is 45.553%
      csscolor4.lch("29.69%", "44.553%", "327.1"),
      csscolor4.lab2lch(csscolor4.lab("29.69%", "44.888%", "-29.04%") --[[@as lab]]),
      0.01
    )
  end)

  it("convert lch to lab", function()
    assert.same_color(
      { "lab", { "none", 0, 0 }, "none" },
      csscolor4.lch2lab({ "lch", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-lab-samples
    --EXAMPLE 23
    --EXAMPLE 24
    assert.same_color(
      { "lab", { 29.2345, 39.3825, 20.0664 }, 0.5 },
      csscolor4.lch2lab({ "lch", { 29.2345, 44.2, 27 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      { "lab", { 52.2345, 40.1645, 59.9971 }, 0.5 },
      csscolor4.lch2lab({ "lch", { 52.2345, 72.2, 56.2 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      { "lab", { 60.2345, -5.3654, 58.9971 }, 0.5 },
      csscolor4.lch2lab({ "lch", { 60.2345, 59.2, 95.2 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "lab", { 62.2345, -34.9638, 47.7721 }, 0.5 },
      csscolor4.lch2lab({ "lch", { 62.2345, 59.2, 126.2 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      { "lab", { 67.5345, -8.6911, -41.6019 }, 0.5 },
      csscolor4.lch2lab({ "lch", { 67.5345, 42.5, 258.2 }, 0.5 }),
      0.0001
    )
    assert.same_color(
      csscolor4.lab("29.69%", "44.888%", "-29.04%"),
      -- The example is 45.553%
      csscolor4.lch2lab(csscolor4.lch("29.69%", "44.553%", "327.1") --[[@as lch]]),
      0.01
    )
  end)
end)

describe("Conversion between oklab and oklch", function()
  it("convert oklab to oklch", function()
    assert.same_color(
      { "oklch", { "none", 0, 0 }, "none" },
      csscolor4.oklab2oklch({ "oklab", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-oklab-samples
    --EXAMPLE 25
    --EXAMPLE 26
    assert.same_color(
      { "oklch", { 0.40101, 0.12332, 21.555 }, 0.5 },
      csscolor4.oklab2oklch({ "oklab", { 0.40101, 0.1147, 0.0453 }, 0.5 }),
      0.01
    )
    assert.same_color(
      { "oklch", { 0.59686, 0.15619, 49.7694 }, 0.5 },
      csscolor4.oklab2oklch({ "oklab", { 0.59686, 0.1009, 0.1192 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "oklch", { 0.65125, 0.13138, 104.097 }, 0.5 },
      csscolor4.oklab2oklch({ "oklab", { 0.65125, -0.0320, 0.1274 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "oklch", { 0.66016, 0.15546, 134.231 }, 0.5 },
      csscolor4.oklab2oklch({ "oklab", { 0.66016, -0.1084, 0.1114 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "oklch", { 0.72322, 0.12403, 247.996 }, 0.5 },
      csscolor4.oklab2oklch({ "oklab", { 0.72322, -0.0465, -0.1150 }, 0.5 }),
      0.1
    )
    assert.same_color(
      csscolor4.oklch("42.1%", "48.25%", "328.4"),
      csscolor4.oklab2oklch(csscolor4.oklab("42.1%", "41%", "-25%") --[[@as oklab]]),
      0.3
    )
  end)

  it("convert oklch to oklab", function()
    assert.same_color(
      { "oklab", { "none", 0, 0 }, "none" },
      csscolor4.oklch2oklab({ "oklch", { "none", "none", "none" }, "none" })
    )

    -- https://www.w3.org/TR/css-color-4/#ex-oklab-samples
    --EXAMPLE 25
    --EXAMPLE 26
    assert.same_color(
      { "oklab", { 0.40101, 0.1147, 0.0453 }, 0.5 },
      csscolor4.oklch2oklab({ "oklch", { 0.40101, 0.12332, 21.555 }, 0.5 }),
      0.01
    )
    assert.same_color(
      { "oklab", { 0.59686, 0.1009, 0.1192 }, 0.5 },
      csscolor4.oklch2oklab({ "oklch", { 0.59686, 0.15619, 49.7694 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "oklab", { 0.65125, -0.0320, 0.1274 }, 0.5 },
      csscolor4.oklch2oklab({ "oklch", { 0.65125, 0.13138, 104.097 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "oklab", { 0.66016, -0.1084, 0.1114 }, 0.5 },
      csscolor4.oklch2oklab({ "oklch", { 0.66016, 0.15546, 134.231 }, 0.5 }),
      0.1
    )
    assert.same_color(
      { "oklab", { 0.72322, -0.0465, -0.1150 }, 0.5 },
      csscolor4.oklch2oklab({ "oklch", { 0.72322, 0.12403, 247.996 }, 0.5 }),
      0.1
    )
    assert.same_color(
      csscolor4.oklab("42.1%", "41%", "-25%"),
      csscolor4.oklch2oklab(csscolor4.oklch("42.1%", "48.25%", "328.4") --[[@as oklch]]),
      0.3
    )
  end)
end)

describe("Conversion between srgb and srgb-linear", function()
  it("convert srgb to srgb-linear", function()
    assert.same_color(
      { "srgb-linear", { "none", "none", "none" }, "none" },
      csscolor4.srgb2srgb_linear({ "srgb", { "none", "none", "none" }, "none" }),
      0.001
    )
    -- https://www.w3.org/TR/css-color-4/#srgb-linear-swatches
    -- EXAMPLE 29
    assert.same_color(
      { "srgb-linear", { 0.435, 0.017, 0.055 }, 0.5 },
      csscolor4.srgb2srgb_linear({ "srgb", { 0.691, 0.139, 0.259 }, 0.5 }),
      0.001
    )
  end)

  it("convert srgb-linear to srgb", function()
    assert.same_color(
      { "srgb", { "none", "none", "none" }, "none" },
      csscolor4.srgb_linear2srgb({ "srgb-linear", { "none", "none", "none" }, "none" }),
      0.01
    )
    -- https://www.w3.org/TR/css-color-4/#srgb-linear-swatches
    -- EXAMPLE 29
    assert.same_color(
      { "srgb", { 0.691, 0.139, 0.259 }, 0.5 },
      csscolor4.srgb_linear2srgb({ "srgb-linear", { 0.435, 0.017, 0.055 }, 0.5 }),
      0.01
    )
  end)
end)

describe("Conversion between display-p3 and display-p3-linear", function()
  it("convert display-p3 to display-p3-linear", function()
    assert.same_color(
      { "display-p3-linear", { "none", "none", "none" }, "none" },
      csscolor4.display_p3_to_display_p3_linear({ "display-p3", { "none", "none", "none" }, "none" }),
      0.001
    )
    -- display-p3-linear is not really a defined color space in the spec.
    -- We reuse the test case of srgb because they share the same algorithm.
    -- https://www.w3.org/TR/css-color-4/#srgb-linear-swatches
    -- EXAMPLE 29
    assert.same_color(
      { "display-p3-linear", { 0.435, 0.017, 0.055 }, 0.5 },
      csscolor4.display_p3_to_display_p3_linear({ "display-p3", { 0.691, 0.139, 0.259 }, 0.5 }),
      0.001
    )
  end)

  it("convert display-p3-linear to display-p3", function()
    assert.same_color(
      { "display-p3", { "none", "none", "none" }, "none" },
      csscolor4.display_p3_linear_to_display_p3({ "display-p3-linear", { "none", "none", "none" }, "none" }),
      0.01
    )
    -- display-p3-linear is not really a defined color space in the spec.
    -- We reuse the test case of srgb because they share the same algorithm.
    -- https://www.w3.org/TR/css-color-4/#srgb-linear-swatches
    -- EXAMPLE 29
    assert.same_color(
      { "display-p3", { 0.691, 0.139, 0.259 }, 0.5 },
      csscolor4.display_p3_linear_to_display_p3({ "display-p3-linear", { 0.435, 0.017, 0.055 }, 0.5 }),
      0.01
    )
  end)
end)

describe("Conversion between prophoto-rgb and prophoto-rgb-linear", function()
  it("convert prophoto-rgb to prophoto-rgb-linear", function()
    assert.same_color(
      { "prophoto-rgb-linear", { "none", "none", "none" }, "none" },
      csscolor4.prophoto_rgb_to_prophoto_rgb_linear({ "prophoto-rgb", { "none", "none", "none" }, "none" })
    )

    assert.same_color(
      { "prophoto-rgb-linear", { 0, -0.001831, 0.002178 }, 0.5 },
      csscolor4.prophoto_rgb_to_prophoto_rgb_linear({ "prophoto-rgb", { 0, -15 / 512, 17 / 512 }, 0.5 })
    )
  end)

  it("convert prophoto-rgb-linear to prophoto-rgb", function()
    assert.same_color(
      { "prophoto-rgb", { "none", "none", "none" }, "none" },
      csscolor4.prophoto_rgb_linear_to_prophoto_rgb({ "prophoto-rgb-linear", { "none", "none", "none" }, "none" })
    )

    assert.same_color(
      { "prophoto-rgb", { 0, -15 / 512, 17 / 512 }, 0.5 },
      csscolor4.prophoto_rgb_linear_to_prophoto_rgb({ "prophoto-rgb-linear", { 0, -0.001831, 0.002178 }, 0.5 })
    )
  end)
end)

describe("Conversion between a98-rgb and a98-rgb-linear", function()
  it("convert a98-rgb to a98-rgb-linear", function()
    assert.same_color(
      { "a98-rgb-linear", { "none", "none", "none" }, "none" },
      csscolor4.a98_rgb_to_a98_rgb_linear({ "a98-rgb", { "none", "none", "none" }, "none" })
    )

    assert.same_color(
      { "a98-rgb-linear", { 0, 1, -1 }, 0.5 },
      csscolor4.a98_rgb_to_a98_rgb_linear({ "a98-rgb", { 0, 1, -1 }, 0.5 })
    )

    assert.same_color(
      { "a98-rgb-linear", { 0, 0.217755, -0.2177555 }, 0.5 },
      csscolor4.a98_rgb_to_a98_rgb_linear({ "a98-rgb", { 0, 0.5, -0.5 }, 0.5 })
    )
  end)

  it("convert a98-rgb-linear to a98-rgb", function()
    assert.same_color(
      { "a98-rgb", { "none", "none", "none" }, "none" },
      csscolor4.a98_rgb_linear_to_a98_rgb({ "a98-rgb-linear", { "none", "none", "none" }, "none" })
    )

    assert.same_color(
      { "a98-rgb", { 0, 1, -1 }, 0.5 },
      csscolor4.a98_rgb_linear_to_a98_rgb({ "a98-rgb-linear", { 0, 1, -1 }, 0.5 })
    )

    assert.same_color(
      { "a98-rgb", { 0, 0.5, -0.5 }, 0.5 },
      csscolor4.a98_rgb_linear_to_a98_rgb({ "a98-rgb-linear", { 0, 0.217755, -0.2177555 }, 0.5 })
    )
  end)
end)

describe("Conversion between rec2020 and rec2020-linear", function()
  it("convert rec2020 to rec2020-linear", function()
    assert.same_color(
      { "rec2020-linear", { "none", "none", "none" }, "none" },
      csscolor4.rec2020_to_rec2020_linear({ "rec2020", { "none", "none", "none" }, "none" })
    )

    assert.same_color(
      { "rec2020-linear", { 0, 0.0177777, 0.259719 }, 0.5 },
      csscolor4.rec2020_to_rec2020_linear({ "rec2020", { 0, 0.08, 0.5 }, 0.5 })
    )
  end)

  it("convert rec2020-linear to rec2020", function()
    assert.same_color(
      { "rec2020", { "none", "none", "none" }, "none" },
      csscolor4.rec2020_linear_to_rec2020({ "rec2020-linear", { "none", "none", "none" }, "none" })
    )

    assert.same_color(
      { "rec2020", { 0, 0.08, 0.5 }, 0.5 },
      csscolor4.rec2020_linear_to_rec2020({ "rec2020-linear", { 0, 0.0177777, 0.259719 }, 0.5 })
    )
  end)
end)

describe("Conversion from srgb-linear to xyz-d65", function()
  it("convert srgb-linear to xyz-d65", function()
    -- "none" is treated as 0.
    assert.same_color(
      { "xyz-d65", { 0, 0, 0 }, "none" },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { "none", "none", "none" }, "none" })
    )

    assert.same_color({ "xyz-d65", { 0, 0, 0 } }, csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 0, 0, 0 } }))

    assert.same_color(
      { "xyz-d65", { 0.9504559270516716, 1.0000000000000004, 1.0890577507598784 } },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 1, 1, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 } },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 1, 0, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.35758433725166943, 0.7151686745033388, 0.11919477979462598 } },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 0, 1, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.18048078840183429, 0.07219231536073371, 0.9505321522496607 } },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 0, 0, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 }, 0.5 },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 1, 0, 0 }, 0.5 }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.20619539963297967, 0.10631950293575514, 0.009665409357795908 }, 1.0 },
      csscolor4.srgb_linear_to_xyz_d65({ "srgb-linear", { 0.5, 0, 0 }, 1.0 }),
      0.001
    )
  end)

  it("convert xyz-d65 to srgb-linear", function()
    assert.same_color(
      { "srgb-linear", { 1, 1, 1 } },
      csscolor4.xyz_d65_to_srgb_linear({ "xyz-d65", { 0.9504559270516717, 1.0000000000000002, 1.0890577507598784 } }),
      0.001
    )

    assert.same_color(
      { "srgb-linear", { 1, 0, 0 } },
      csscolor4.xyz_d65_to_srgb_linear({ "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 } }),
      0.001
    )

    assert.same_color(
      { "srgb-linear", { 0, 1, 0 } },
      csscolor4.xyz_d65_to_srgb_linear({ "xyz-d65", { 0.35758433725166943, 0.7151686745033388, 0.11919477979462598 } }),
      0.001
    )

    assert.same_color(
      { "srgb-linear", { 0, 0, 1 } },
      csscolor4.xyz_d65_to_srgb_linear({ "xyz-d65", { 0.18048078840183429, 0.07219231536073371, 0.9505321522496607 } }),
      0.001
    )

    assert.same_color(
      { "srgb-linear", { 1, 0, 0 }, 0.5 },
      csscolor4.xyz_d65_to_srgb_linear({
        "xyz-d65",
        { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 },
        0.5,
      }),
      0.001
    )

    assert.same_color(
      { "srgb-linear", { 0.5, 0, 0 }, 1.0 },
      csscolor4.xyz_d65_to_srgb_linear({
        "xyz-d65",
        { 0.20619539963297967, 0.10631950293575514, 0.009665409357795908 },
        1.0,
      }),
      0.001
    )

    assert.same_color(
      { "srgb-linear", { 0, 0, 0 } },
      csscolor4.xyz_d65_to_srgb_linear({ "xyz-d65", { "none", "none", "none" } })
    )

    assert.same_color(
      { "srgb-linear", { -0.58493281030158, 0.17492985562943, 0.98995983935743 } },
      csscolor4.xyz_d65_to_srgb_linear({ "xyz-d65", { "none", 0.07219231536073371, 0.9505321522496607 } }),
      0.001
    )
  end)
end)

describe("srgb_linear and xyz_d65 conversions", function()
  it("should be inverse operations", function()
    local original_srgb = { "srgb-linear", { 0.5, 0.3, 0.8 }, 0.9 }
    local xyz_result = csscolor4.srgb_linear_to_xyz_d65(original_srgb)
    local final_srgb = csscolor4.xyz_d65_to_srgb_linear(xyz_result)
    assert.same_color(original_srgb, final_srgb, 0.000001)

    local original_xyz = { "xyz-d65", { 0.4, 0.6, 0.2 }, 0.7 }
    local srgb_result = csscolor4.xyz_d65_to_srgb_linear(original_xyz)
    local final_xyz = csscolor4.srgb_linear_to_xyz_d65(srgb_result)
    assert.same_color(original_xyz, final_xyz, 0.000001)

    local black_srgb = { "srgb-linear", { 0, 0, 0 } }
    local black_xyz = csscolor4.srgb_linear_to_xyz_d65(black_srgb)
    local black_back = csscolor4.xyz_d65_to_srgb_linear(black_xyz)
    assert.same_color(black_srgb, black_back, 0.000001)

    local white_srgb = { "srgb-linear", { 1, 1, 1 } }
    local white_xyz = csscolor4.srgb_linear_to_xyz_d65(white_srgb)
    local white_back = csscolor4.xyz_d65_to_srgb_linear(white_xyz)
    assert.same_color(white_srgb, white_back, 0.000001)

    local red_srgb = { "srgb-linear", { 1, 0, 0 } }
    local red_xyz = csscolor4.srgb_linear_to_xyz_d65(red_srgb)
    local red_back = csscolor4.xyz_d65_to_srgb_linear(red_xyz)
    assert.same_color(red_srgb, red_back, 0.000001)

    local green_srgb = { "srgb-linear", { 0, 1, 0 } }
    local green_xyz = csscolor4.srgb_linear_to_xyz_d65(green_srgb)
    local green_back = csscolor4.xyz_d65_to_srgb_linear(green_xyz)
    assert.same_color(green_srgb, green_back, 0.000001)

    local blue_srgb = { "srgb-linear", { 0, 0, 1 } }
    local blue_xyz = csscolor4.srgb_linear_to_xyz_d65(blue_srgb)
    local blue_back = csscolor4.xyz_d65_to_srgb_linear(blue_xyz)
    assert.same_color(blue_srgb, blue_back, 0.000001)

    local in_gamut_xyz = { "xyz-d65", { 0, 0.07219231536073371, 0.9505321522496607 }, 0.8 }
    local out_of_gamut_srgb = csscolor4.xyz_d65_to_srgb_linear(in_gamut_xyz)
    local back_to_xyz = csscolor4.srgb_linear_to_xyz_d65(out_of_gamut_srgb)
    assert.same_color(in_gamut_xyz, back_to_xyz, 0.000001)
  end)
end)

describe("display_p3_linear and xyz_d65 conversions", function()
  it("convert display-p3-linear to xyz-d65", function()
    assert.same_color(
      { "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } },
      csscolor4.display_p3_linear_to_xyz_d65({ "display-p3-linear", { 1, 1, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.48657094864821626, 0.22897456406974884, 0 } },
      csscolor4.display_p3_linear_to_xyz_d65({ "display-p3-linear", { 1, 0, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.26566769316909294, 0.6917385218365062, 0.045113381858902575 } },
      csscolor4.display_p3_linear_to_xyz_d65({ "display-p3-linear", { 0, 1, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.1982172852343625, 0.079286914093745, 1.0439443689009757 } },
      csscolor4.display_p3_linear_to_xyz_d65({ "display-p3-linear", { 0, 0, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.24328547432410813, 0.11448728203487442, 0 }, 0.5 },
      csscolor4.display_p3_linear_to_xyz_d65({ "display-p3-linear", { 0.5, 0, 0 }, 0.5 }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0, 0, 0 } },
      csscolor4.display_p3_linear_to_xyz_d65({ "display-p3-linear", { "none", "none", "none" } })
    )
  end)

  it("convert xyz-d65 to display-p3-linear", function()
    assert.same_color(
      { "display-p3-linear", { 1, 1, 1 } },
      csscolor4.xyz_d65_to_display_p3_linear({ "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } }),
      0.001
    )

    assert.same_color(
      { "display-p3-linear", { 1, 0, 0 } },
      csscolor4.xyz_d65_to_display_p3_linear({ "xyz-d65", { 0.48657094864821626, 0.22897456406974884, 0 } }),
      0.001
    )

    assert.same_color(
      { "display-p3-linear", { 0, 1, 0 } },
      csscolor4.xyz_d65_to_display_p3_linear({
        "xyz-d65",
        { 0.26566769316909294, 0.6917385218365062, 0.045113381858902575 },
      }),
      0.001
    )

    assert.same_color(
      { "display-p3-linear", { 0, 0, 1 } },
      csscolor4.xyz_d65_to_display_p3_linear({
        "xyz-d65",
        { 0.1982172852343625, 0.079286914093745, 1.0439443689009757 },
      }),
      0.001
    )

    assert.same_color(
      { "display-p3-linear", { 0.5, 0, 0 }, 0.5 },
      csscolor4.xyz_d65_to_display_p3_linear({
        "xyz-d65",
        { 0.24328547432410813, 0.11448728203487442, 0 },
        0.5,
      }),
      0.001
    )

    assert.same_color(
      { "display-p3-linear", { 0, 0, 0 } },
      csscolor4.xyz_d65_to_display_p3_linear({ "xyz-d65", { "none", "none", "none" } })
    )
  end)

  it("should be inverse operations", function()
    local original_p3 = { "display-p3-linear", { 0.5, 0.3, 0.8 }, 0.9 }
    local xyz_result = csscolor4.display_p3_linear_to_xyz_d65(original_p3)
    local final_p3 = csscolor4.xyz_d65_to_display_p3_linear(xyz_result)
    assert.same_color(original_p3, final_p3, 0.000001)

    local original_xyz = { "xyz-d65", { 0.4, 0.6, 0.2 }, 0.7 }
    local p3_result = csscolor4.xyz_d65_to_display_p3_linear(original_xyz)
    local final_xyz = csscolor4.display_p3_linear_to_xyz_d65(p3_result)
    assert.same_color(original_xyz, final_xyz, 0.000001)

    local black_p3 = { "display-p3-linear", { 0, 0, 0 } }
    local black_xyz = csscolor4.display_p3_linear_to_xyz_d65(black_p3)
    local black_back = csscolor4.xyz_d65_to_display_p3_linear(black_xyz)
    assert.same_color(black_p3, black_back, 0.000001)

    local white_p3 = { "display-p3-linear", { 1, 1, 1 } }
    local white_xyz = csscolor4.display_p3_linear_to_xyz_d65(white_p3)
    local white_back = csscolor4.xyz_d65_to_display_p3_linear(white_xyz)
    assert.same_color(white_p3, white_back, 0.000001)

    local red_p3 = { "display-p3-linear", { 1, 0, 0 } }
    local red_xyz = csscolor4.display_p3_linear_to_xyz_d65(red_p3)
    local red_back = csscolor4.xyz_d65_to_display_p3_linear(red_xyz)
    assert.same_color(red_p3, red_back, 0.000001)

    local green_p3 = { "display-p3-linear", { 0, 1, 0 } }
    local green_xyz = csscolor4.display_p3_linear_to_xyz_d65(green_p3)
    local green_back = csscolor4.xyz_d65_to_display_p3_linear(green_xyz)
    assert.same_color(green_p3, green_back, 0.000001)

    local blue_p3 = { "display-p3-linear", { 0, 0, 1 } }
    local blue_xyz = csscolor4.display_p3_linear_to_xyz_d65(blue_p3)
    local blue_back = csscolor4.xyz_d65_to_display_p3_linear(blue_xyz)
    assert.same_color(blue_p3, blue_back, 0.000001)
  end)
end)

describe("a98_rgb_linear and xyz_d65 conversions", function()
  it("convert a98-rgb-linear to xyz-d65", function()
    assert.same_color(
      { "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } },
      csscolor4.a98_rgb_linear_to_xyz_d65({ "a98-rgb-linear", { 1, 1, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.5766690429101305, 0.2973231235015054, 0.027041361067437535 } },
      csscolor4.a98_rgb_linear_to_xyz_d65({ "a98-rgb-linear", { 1, 0, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.18555823790655, 0.62736356625547, 0.070688852535827 } },
      csscolor4.a98_rgb_linear_to_xyz_d65({ "a98-rgb-linear", { 0, 1, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.18822864623499, 0.075291458493998, 0.99133753683764 } },
      csscolor4.a98_rgb_linear_to_xyz_d65({ "a98-rgb-linear", { 0, 0, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.28833452145506526, 0.14866156175075268, 0.013520680533718767 }, 0.5 },
      csscolor4.a98_rgb_linear_to_xyz_d65({ "a98-rgb-linear", { 0.5, 0, 0 }, 0.5 }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0, 0, 0 } },
      csscolor4.a98_rgb_linear_to_xyz_d65({ "a98-rgb-linear", { "none", "none", "none" } })
    )
  end)

  it("convert xyz-d65 to a98-rgb-linear", function()
    assert.same_color(
      { "a98-rgb-linear", { 1, 1, 1 } },
      csscolor4.xyz_d65_to_a98_rgb_linear({ "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } }),
      0.001
    )

    assert.same_color(
      { "a98-rgb-linear", { 1, 0, 0 } },
      csscolor4.xyz_d65_to_a98_rgb_linear({
        "xyz-d65",
        { 0.5766690429101305, 0.2973231235015054, 0.027041361067437535 },
      }),
      0.001
    )

    assert.same_color(
      { "a98-rgb-linear", { 0, 1, 0 } },
      csscolor4.xyz_d65_to_a98_rgb_linear({ "xyz-d65", { 0.18555823790655, 0.62736356625547, 0.070688852535827 } }),
      0.001
    )

    assert.same_color(
      { "a98-rgb-linear", { 0, 0, 1 } },
      csscolor4.xyz_d65_to_a98_rgb_linear({ "xyz-d65", { 0.18822864623499, 0.075291458493998, 0.99133753683764 } }),
      0.001
    )

    assert.same_color(
      { "a98-rgb-linear", { 0.5, 0, 0 }, 0.5 },
      csscolor4.xyz_d65_to_a98_rgb_linear({
        "xyz-d65",
        { 0.28833452145506526, 0.14866156175075268, 0.013520680533718767 },
        0.5,
      }),
      0.001
    )

    assert.same_color(
      { "a98-rgb-linear", { 0, 0, 0 } },
      csscolor4.xyz_d65_to_a98_rgb_linear({ "xyz-d65", { "none", "none", "none" } })
    )
  end)

  it("should be inverse operations", function()
    local original_a98 = { "a98-rgb-linear", { 0.5, 0.3, 0.8 }, 0.9 }
    local xyz_result = csscolor4.a98_rgb_linear_to_xyz_d65(original_a98)
    local final_a98 = csscolor4.xyz_d65_to_a98_rgb_linear(xyz_result)
    assert.same_color(original_a98, final_a98, 0.000001)

    local original_xyz = { "xyz-d65", { 0.4, 0.6, 0.2 }, 0.7 }
    local a98_result = csscolor4.xyz_d65_to_a98_rgb_linear(original_xyz)
    local final_xyz = csscolor4.a98_rgb_linear_to_xyz_d65(a98_result)
    assert.same_color(original_xyz, final_xyz, 0.000001)

    local black_a98 = { "a98-rgb-linear", { 0, 0, 0 } }
    local black_xyz = csscolor4.a98_rgb_linear_to_xyz_d65(black_a98)
    local black_back = csscolor4.xyz_d65_to_a98_rgb_linear(black_xyz)
    assert.same_color(black_a98, black_back, 0.000001)

    local white_a98 = { "a98-rgb-linear", { 1, 1, 1 } }
    local white_xyz = csscolor4.a98_rgb_linear_to_xyz_d65(white_a98)
    local white_back = csscolor4.xyz_d65_to_a98_rgb_linear(white_xyz)
    assert.same_color(white_a98, white_back, 0.000001)

    local red_a98 = { "a98-rgb-linear", { 1, 0, 0 } }
    local red_xyz = csscolor4.a98_rgb_linear_to_xyz_d65(red_a98)
    local red_back = csscolor4.xyz_d65_to_a98_rgb_linear(red_xyz)
    assert.same_color(red_a98, red_back, 0.000001)

    local green_a98 = { "a98-rgb-linear", { 0, 1, 0 } }
    local green_xyz = csscolor4.a98_rgb_linear_to_xyz_d65(green_a98)
    local green_back = csscolor4.xyz_d65_to_a98_rgb_linear(green_xyz)
    assert.same_color(green_a98, green_back, 0.000001)

    local blue_a98 = { "a98-rgb-linear", { 0, 0, 1 } }
    local blue_xyz = csscolor4.a98_rgb_linear_to_xyz_d65(blue_a98)
    local blue_back = csscolor4.xyz_d65_to_a98_rgb_linear(blue_xyz)
    assert.same_color(blue_a98, blue_back, 0.000001)
  end)
end)

describe("xyz_d65_to_rec2020_linear and rec2020_linear_to_xyz_d65", function()
  it("should convert xyz_d65 to rec2020_linear", function()
    assert.same_color(
      { "rec2020-linear", { 0, 0, 0 } },
      csscolor4.xyz_d65_to_rec2020_linear({ "xyz-d65", { 0, 0, 0 } })
    )

    assert.same_color(
      { "rec2020-linear", { 1, 1, 1 } },
      csscolor4.xyz_d65_to_rec2020_linear({ "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } }),
      0.001
    )

    assert.same_color(
      { "rec2020-linear", { 1, 0, 0 } },
      csscolor4.xyz_d65_to_rec2020_linear({ "xyz-d65", { 0.6369580483012913, 0.26270021201126703, 0 } }),
      0.001
    )

    assert.same_color(
      { "rec2020-linear", { 0, 1, 0 } },
      csscolor4.xyz_d65_to_rec2020_linear({
        "xyz-d65",
        { 0.14461690358620838, 0.677998071518871, 0.028072693049087508 },
      }),
      0.001
    )

    assert.same_color(
      { "rec2020-linear", { 0, 0, 1 } },
      csscolor4.xyz_d65_to_rec2020_linear({
        "xyz-d65",
        { 0.16888097516417205, 0.059301716469861945, 1.0609850577107909 },
      }),
      0.001
    )

    assert.same_color(
      { "rec2020-linear", { 0.43866954005518244, 0.04829371310216819, 0.011465709023130176 }, 0.5 },
      csscolor4.xyz_d65_to_rec2020_linear({
        "xyz-d65",
        { 0.28833452145506526, 0.14866156175075268, 0.013520680533718767 },
        0.5,
      }),
      0.001
    )

    assert.same_color(
      { "rec2020-linear", { 0, 0, 0 } },
      csscolor4.xyz_d65_to_rec2020_linear({ "xyz-d65", { "none", "none", "none" } })
    )
  end)

  it("should convert rec2020_linear to xyz_d65", function()
    assert.same_color(
      { "xyz-d65", { 0, 0, 0 } },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { 0, 0, 0 } })
    )

    assert.same_color(
      { "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { 1, 1, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.6369580483012913, 0.26270021201126703, 0 } },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { 1, 0, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.14461690358620838, 0.677998071518871, 0.028072693049087508 } },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { 0, 1, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.16888097516417205, 0.059301716469861945, 1.0609850577107909 } },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { 0, 0, 1 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0.49696887535784584, 0.3821909006371844, 0.857209854083359 }, 0.5 },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { 0.5, 0.3, 0.8 }, 0.5 }),
      0.001
    )

    assert.same_color(
      { "xyz-d65", { 0, 0, 0 } },
      csscolor4.rec2020_linear_to_xyz_d65({ "rec2020-linear", { "none", "none", "none" } })
    )
  end)

  it("should be inverse operations", function()
    local original_rec2020 = { "rec2020-linear", { 0.5, 0.3, 0.8 }, 0.9 }
    local xyz_result = csscolor4.rec2020_linear_to_xyz_d65(original_rec2020)
    local final_rec2020 = csscolor4.xyz_d65_to_rec2020_linear(xyz_result)
    assert.same_color(original_rec2020, final_rec2020, 0.000001)

    local original_xyz = { "xyz-d65", { 0.4, 0.6, 0.2 }, 0.7 }
    local rec2020_result = csscolor4.xyz_d65_to_rec2020_linear(original_xyz)
    local final_xyz = csscolor4.rec2020_linear_to_xyz_d65(rec2020_result)
    assert.same_color(original_xyz, final_xyz, 0.000001)

    local black_rec2020 = { "rec2020-linear", { 0, 0, 0 } }
    local black_xyz = csscolor4.rec2020_linear_to_xyz_d65(black_rec2020)
    local black_back = csscolor4.xyz_d65_to_rec2020_linear(black_xyz)
    assert.same_color(black_rec2020, black_back, 0.000001)

    local white_rec2020 = { "rec2020-linear", { 1, 1, 1 } }
    local white_xyz = csscolor4.rec2020_linear_to_xyz_d65(white_rec2020)
    local white_back = csscolor4.xyz_d65_to_rec2020_linear(white_xyz)
    assert.same_color(white_rec2020, white_back, 0.000001)

    local red_rec2020 = { "rec2020-linear", { 1, 0, 0 } }
    local red_xyz = csscolor4.rec2020_linear_to_xyz_d65(red_rec2020)
    local red_back = csscolor4.xyz_d65_to_rec2020_linear(red_xyz)
    assert.same_color(red_rec2020, red_back, 0.000001)

    local green_rec2020 = { "rec2020-linear", { 0, 1, 0 } }
    local green_xyz = csscolor4.rec2020_linear_to_xyz_d65(green_rec2020)
    local green_back = csscolor4.xyz_d65_to_rec2020_linear(green_xyz)
    assert.same_color(green_rec2020, green_back, 0.000001)

    local blue_rec2020 = { "rec2020-linear", { 0, 0, 1 } }
    local blue_xyz = csscolor4.rec2020_linear_to_xyz_d65(blue_rec2020)
    local blue_back = csscolor4.xyz_d65_to_rec2020_linear(blue_xyz)
    assert.same_color(blue_rec2020, blue_back, 0.000001)
  end)
end)

describe("xyz_d65_to_oklab and oklab_to_xyz_d65", function()
  it("should convert xyz_d65 to oklab", function()
    -- Test basic colors
    assert.same_color({ "oklab", { 0, 0, 0 } }, csscolor4.xyz_d65_to_oklab({ "xyz-d65", { 0, 0, 0 } }))

    -- Test white point D65 -> OKLab white
    assert.same_color(
      { "oklab", { 1.0000000000000002, 0, 0 } },
      csscolor4.xyz_d65_to_oklab({ "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } }),
      0.000001
    )

    -- Test red
    assert.same_color(
      { "oklab", { 0.6279553606146136, 0.22486306106597616, 0.1258462884898379 } },
      csscolor4.xyz_d65_to_oklab({ "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 } }),
      0.000001
    )

    -- Test green
    assert.same_color(
      { "oklab", { 0.8664396206938455, -0.2338875814103562, 0.17952624564654574 } },
      csscolor4.xyz_d65_to_oklab({ "xyz-d65", { 0.35758433725166943, 0.7151686745033388, 0.11919477979462598 } }),
      0.0001
    )

    -- Test blue
    assert.same_color(
      { "oklab", { 0.4520137183853429, -0.032456603746157885, -0.31152619472426474 } },
      csscolor4.xyz_d65_to_oklab({ "xyz-d65", { 0.18048078840183429, 0.07219231536073371, 0.9505321522496607 } }),
      0.0001
    )

    -- Test with alpha
    assert.same_color(
      { "oklab", { 0.6279553606146136, 0.22486306106597616, 0.1258462884898379 }, 0.5 },
      csscolor4.xyz_d65_to_oklab({
        "xyz-d65",
        { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 },
        0.5,
      }),
      0.000001
    )

    -- Test "none" values
    assert.same_color({ "oklab", { 0, 0, 0 } }, csscolor4.xyz_d65_to_oklab({ "xyz-d65", { "none", "none", "none" } }))
  end)

  it("should convert oklab to xyz_d65", function()
    -- Test basic colors
    assert.same_color({ "xyz-d65", { 0, 0, 0 } }, csscolor4.oklab_to_xyz_d65({ "oklab", { 0, 0, 0 } }))

    -- Test white
    assert.same_color(
      { "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } },
      csscolor4.oklab_to_xyz_d65({ "oklab", { 1.0000000000000002, 0, 0 } }),
      0.000001
    )

    -- Test red
    assert.same_color(
      { "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 } },
      csscolor4.oklab_to_xyz_d65({ "oklab", { 0.6279553606146136, 0.22486306106597616, 0.1258462884898379 } }),
      0.000001
    )

    -- Test green
    assert.same_color(
      { "xyz-d65", { 0.35758433725166943, 0.7151686745033388, 0.11919477979462598 } },
      csscolor4.oklab_to_xyz_d65({ "oklab", { 0.8664396206938455, -0.2338875814103562, 0.17952624564654574 } }),
      0.0001
    )

    -- Test blue
    assert.same_color(
      { "xyz-d65", { 0.18048078840183429, 0.07219231536073371, 0.9505321522496607 } },
      csscolor4.oklab_to_xyz_d65({ "oklab", { 0.4520137183853429, -0.032456603746157885, -0.31152619472426474 } }),
      0.0001
    )

    -- Test with alpha
    assert.same_color(
      { "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 }, 0.5 },
      csscolor4.oklab_to_xyz_d65({
        "oklab",
        { 0.6279553606146136, 0.22486306106597616, 0.1258462884898379 },
        0.5,
      }),
      0.000001
    )

    -- Test "none" values
    assert.same_color({ "xyz-d65", { 0, 0, 0 } }, csscolor4.oklab_to_xyz_d65({ "oklab", { "none", "none", "none" } }))
  end)

  it("should be reversible", function()
    -- Test round-trip conversions
    local original_xyz = { "xyz-d65", { 0.5, 0.3, 0.8 } }
    local oklab_result = csscolor4.xyz_d65_to_oklab(original_xyz)
    local final_xyz = csscolor4.oklab_to_xyz_d65(oklab_result)
    assert.same_color(original_xyz, final_xyz, 0.000001)

    local original_oklab = { "oklab", { 0.7, 0.1, -0.05 } }
    local xyz_result = csscolor4.oklab_to_xyz_d65(original_oklab)
    local final_oklab = csscolor4.xyz_d65_to_oklab(xyz_result)
    assert.same_color(original_oklab, final_oklab, 0.000001)

    -- Test basic colors round-trip
    local black_xyz = { "xyz-d65", { 0, 0, 0 } }
    local black_oklab = csscolor4.xyz_d65_to_oklab(black_xyz)
    local black_back = csscolor4.oklab_to_xyz_d65(black_oklab)
    assert.same_color(black_xyz, black_back, 0.000001)

    local white_xyz = { "xyz-d65", { 0.9504559270516717, 1, 1.0890577507598784 } }
    local white_oklab = csscolor4.xyz_d65_to_oklab(white_xyz)
    local white_back = csscolor4.oklab_to_xyz_d65(white_oklab)
    assert.same_color(white_xyz, white_back, 0.000001)

    local red_xyz = { "xyz-d65", { 0.41239079926595934, 0.21263900587151027, 0.01933081871559182 } }
    local red_oklab = csscolor4.xyz_d65_to_oklab(red_xyz)
    local red_back = csscolor4.oklab_to_xyz_d65(red_oklab)
    assert.same_color(red_xyz, red_back, 0.000001)

    local green_xyz = { "xyz-d65", { 0.35758433725166943, 0.7151686745033388, 0.11919477979462598 } }
    local green_oklab = csscolor4.xyz_d65_to_oklab(green_xyz)
    local green_back = csscolor4.oklab_to_xyz_d65(green_oklab)
    assert.same_color(green_xyz, green_back, 0.000001)

    local blue_xyz = { "xyz-d65", { 0.18048078840183429, 0.07219231536073371, 0.9505321522496607 } }
    local blue_oklab = csscolor4.xyz_d65_to_oklab(blue_xyz)
    local blue_back = csscolor4.oklab_to_xyz_d65(blue_oklab)
    assert.same_color(blue_xyz, blue_back, 0.000001)
  end)
end)

describe("ProPhoto RGB conversions", function()
  it("xyz_d50_to_prophoto_rgb_linear", function()
    -- Test conversion from XYZ D50 to ProPhoto RGB linear
    assert.same_color(
      { "prophoto-rgb-linear", { 0, 0, 0 } },
      csscolor4.xyz_d50_to_prophoto_rgb_linear({ "xyz-d50", { 0, 0, 0 } })
    )

    -- Test with a known color (approximate sRGB red converted to XYZ D50)
    assert.same_color(
      { "prophoto-rgb-linear", { 0.5293, 0.0984, 0.0168 } },
      csscolor4.xyz_d50_to_prophoto_rgb_linear({ "xyz-d50", { 0.4361, 0.2225, 0.0139 } }),
      0.001
    )

    -- Test with a known color (approximate sRGB green converted to XYZ D50)
    assert.same_color(
      { "prophoto-rgb-linear", { 0.3301, 0.8735, 0.1177 } },
      csscolor4.xyz_d50_to_prophoto_rgb_linear({ "xyz-d50", { 0.3851, 0.7169, 0.0971 } }),
      0.001
    )

    -- Test with a known color (approximate sRGB blue converted to XYZ D50)
    assert.same_color(
      { "prophoto-rgb-linear", { 0.1406, 0.0281, 0.8655 } },
      csscolor4.xyz_d50_to_prophoto_rgb_linear({ "xyz-d50", { 0.1431, 0.0606, 0.7141 } }),
      0.001
    )

    -- Test "none" values
    assert.same_color(
      { "prophoto-rgb-linear", { 0, 0, 0 } },
      csscolor4.xyz_d50_to_prophoto_rgb_linear({ "xyz-d50", { "none", "none", "none" } })
    )
  end)

  it("prophoto_rgb_linear_to_xyz_d50", function()
    -- Test conversion from ProPhoto RGB linear to XYZ D50
    assert.same_color(
      { "xyz-d50", { 0, 0, 0 } },
      csscolor4.prophoto_rgb_linear_to_xyz_d50({ "prophoto-rgb-linear", { 0, 0, 0 } })
    )

    -- Test with known ProPhoto RGB linear values
    assert.same_color(
      { "xyz-d50", { 0.7978, 0.2881, 0.0000 } },
      csscolor4.prophoto_rgb_linear_to_xyz_d50({ "prophoto-rgb-linear", { 1, 0, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d50", { 0.1352, 0.7118, 0.0000 } },
      csscolor4.prophoto_rgb_linear_to_xyz_d50({ "prophoto-rgb-linear", { 0, 1, 0 } }),
      0.001
    )

    assert.same_color(
      { "xyz-d50", { 0.0313, 0.0001, 0.8251 } },
      csscolor4.prophoto_rgb_linear_to_xyz_d50({ "prophoto-rgb-linear", { 0, 0, 1 } }),
      0.001
    )

    -- Test "none" values
    assert.same_color(
      { "xyz-d50", { 0, 0, 0 } },
      csscolor4.prophoto_rgb_linear_to_xyz_d50({ "prophoto-rgb-linear", { "none", "none", "none" } })
    )
  end)

  it("should be reversible", function()
    -- Test round-trip conversions
    local original_xyz = { "xyz-d50", { 0.5, 0.3, 0.8 } }
    local prophoto_result = csscolor4.xyz_d50_to_prophoto_rgb_linear(original_xyz)
    local final_xyz = csscolor4.prophoto_rgb_linear_to_xyz_d50(prophoto_result)
    assert.same_color(original_xyz, final_xyz, 0.000001)

    local original_prophoto = { "prophoto-rgb-linear", { 0.7, 0.5, 0.3 } }
    local xyz_result = csscolor4.prophoto_rgb_linear_to_xyz_d50(original_prophoto)
    local final_prophoto = csscolor4.xyz_d50_to_prophoto_rgb_linear(xyz_result)
    assert.same_color(original_prophoto, final_prophoto, 0.000001)

    -- Test basic colors round-trip
    local black_xyz = { "xyz-d50", { 0, 0, 0 } }
    local black_prophoto = csscolor4.xyz_d50_to_prophoto_rgb_linear(black_xyz)
    local black_back = csscolor4.prophoto_rgb_linear_to_xyz_d50(black_prophoto)
    assert.same_color(black_xyz, black_back, 0.000001)

    -- Test primary colors (red channel)
    local red_prophoto = { "prophoto-rgb-linear", { 1, 0, 0 } }
    local red_xyz = csscolor4.prophoto_rgb_linear_to_xyz_d50(red_prophoto)
    local red_back = csscolor4.xyz_d50_to_prophoto_rgb_linear(red_xyz)
    assert.same_color(red_prophoto, red_back, 0.000001)

    -- Test primary colors (green channel)
    local green_prophoto = { "prophoto-rgb-linear", { 0, 1, 0 } }
    local green_xyz = csscolor4.prophoto_rgb_linear_to_xyz_d50(green_prophoto)
    local green_back = csscolor4.xyz_d50_to_prophoto_rgb_linear(green_xyz)
    assert.same_color(green_prophoto, green_back, 0.000001)

    -- Test primary colors (blue channel)
    local blue_prophoto = { "prophoto-rgb-linear", { 0, 0, 1 } }
    local blue_xyz = csscolor4.prophoto_rgb_linear_to_xyz_d50(blue_prophoto)
    local blue_back = csscolor4.xyz_d50_to_prophoto_rgb_linear(blue_xyz)
    assert.same_color(blue_prophoto, blue_back, 0.000001)
  end)
end)

describe("xyz_d50 and lab conversions", function()
  it("convert xyz-d50 to lab", function()
    -- Test D50 white point conversion
    local white_xyz = { "xyz-d50", { 0.9642956764295677, 1, 0.8251046025104602 } }
    local white_lab = csscolor4.xyz_d50_to_lab(white_xyz)
    assert.same_color({ "lab", { 100, 0, 0 } }, white_lab, 0.001)

    -- Test black point conversion
    local black_xyz = { "xyz-d50", { 0, 0, 0 } }
    local black_lab = csscolor4.xyz_d50_to_lab(black_xyz)
    assert.same_color({ "lab", { 0, 0, 0 } }, black_lab, 0.001)

    -- Test mid-gray conversion
    local gray_xyz = { "xyz-d50", { 0.18372, 0.19329, 0.15714 } }
    local gray_lab = csscolor4.xyz_d50_to_lab(gray_xyz)
    assert.same_color({ "lab", { 51.069919422613, -1.3863883843706, 0.56943599902164 } }, gray_lab, 0.01)
  end)

  it("convert lab to xyz-d50", function()
    -- Test white point conversion
    local white_lab = { "lab", { 100, 0, 0 } }
    local white_xyz = csscolor4.lab_to_xyz_d50(white_lab)
    assert.same_color({ "xyz-d50", { 0.9642956764295677, 1, 0.8251046025104602 } }, white_xyz, 0.001)

    -- Test black point conversion
    local black_lab = { "lab", { 0, 0, 0 } }
    local black_xyz = csscolor4.lab_to_xyz_d50(black_lab)
    assert.same_color({ "xyz-d50", { 0, 0, 0 } }, black_xyz, 0.001)

    -- Test mid-gray conversion
    local gray_lab = { "lab", { 51.069919422613, -1.3863883843706, 0.56943599902164 } }
    local gray_xyz = csscolor4.lab_to_xyz_d50(gray_lab)
    assert.same_color({ "xyz-d50", { 0.18372, 0.19329, 0.15714 } }, gray_xyz, 0.01)
  end)

  it("round-trip conversions xyz-d50 <-> lab", function()
    -- Test round-trip conversion for white point
    local white_xyz = { "xyz-d50", { 0.9642956764295677, 1, 0.8251046025104602 } }
    local white_lab = csscolor4.xyz_d50_to_lab(white_xyz)
    local white_back = csscolor4.lab_to_xyz_d50(white_lab)
    assert.same_color(white_xyz, white_back, 0.000001)

    -- Test round-trip conversion for black
    local black_xyz = { "xyz-d50", { 0, 0, 0 } }
    local black_lab = csscolor4.xyz_d50_to_lab(black_xyz)
    local black_back = csscolor4.lab_to_xyz_d50(black_lab)
    assert.same_color(black_xyz, black_back, 0.000001)

    -- Test round-trip conversion for mid-gray
    local gray_xyz = { "xyz-d50", { 0.18372, 0.19329, 0.15714 } }
    local gray_lab = csscolor4.xyz_d50_to_lab(gray_xyz)
    local gray_back = csscolor4.lab_to_xyz_d50(gray_lab)
    assert.same_color(gray_xyz, gray_back, 0.000001)

    -- Test round-trip with alpha
    local xyz_with_alpha = { "xyz-d50", { 0.5, 0.5, 0.5 }, 0.7 }
    local lab_with_alpha = csscolor4.xyz_d50_to_lab(xyz_with_alpha)
    local xyz_back = csscolor4.lab_to_xyz_d50(lab_with_alpha)
    assert.same_color(xyz_with_alpha, xyz_back, 0.000001)

    -- Test with "none" values
    local xyz_with_none = { "xyz-d50", { "none", 0.5, "none" } }
    local lab_with_processed_none = csscolor4.xyz_d50_to_lab(xyz_with_none)
    local xyz_back_none = csscolor4.lab_to_xyz_d50(lab_with_processed_none)
    -- "none" values get converted to 0, so we expect zeros
    assert.same_color({ "xyz-d50", { 0, 0.5, 0 } }, xyz_back_none, 0.000001)
  end)
end)

describe("Chromatic adaptation between D65 and D50", function()
  it("convert xyz-d65 to xyz-d50", function()
    -- Test white point conversion (D65 white point to D50 white point)
    local white_d65 = { "xyz-d65", { 0.95047, 1.0, 1.08883 } }
    local white_d50 = csscolor4.xyz_d65_to_xyz_d50(white_d65)
    assert.same_color({ "xyz-d50", { 0.9642956764295677, 1, 0.8251046025104602 } }, white_d50, 0.001)

    -- Test black point conversion
    local black_d65 = { "xyz-d65", { 0, 0, 0 } }
    local black_d50 = csscolor4.xyz_d65_to_xyz_d50(black_d65)
    assert.same_color({ "xyz-d50", { 0, 0, 0 } }, black_d50, 0.000001)

    -- Test with alpha
    local xyz_with_alpha = { "xyz-d65", { 0.5, 0.6, 0.7 }, 0.8 }
    local result = csscolor4.xyz_d65_to_xyz_d50(xyz_with_alpha)
    assert.same(0.8, result[3])
  end)

  it("convert xyz-d50 to xyz-d65", function()
    -- Test white point conversion (D50 white point to D65 white point)
    local white_d50 = { "xyz-d50", { 0.9642956764295677, 1, 0.8251046025104602 } }
    local white_d65 = csscolor4.xyz_d50_to_xyz_d65(white_d50)
    assert.same_color({ "xyz-d65", { 0.95047, 1.0, 1.08883 } }, white_d65, 0.001)

    -- Test black point conversion
    local black_d50 = { "xyz-d50", { 0, 0, 0 } }
    local black_d65 = csscolor4.xyz_d50_to_xyz_d65(black_d50)
    assert.same_color({ "xyz-d65", { 0, 0, 0 } }, black_d65, 0.000001)

    -- Test with alpha
    local xyz_with_alpha = { "xyz-d50", { 0.5, 0.6, 0.7 }, 0.8 }
    local result = csscolor4.xyz_d50_to_xyz_d65(xyz_with_alpha)
    assert.same(0.8, result[3])
  end)

  it("round-trip conversions xyz-d65 <-> xyz-d50", function()
    -- Test round-trip conversion for white point
    local white_d65 = { "xyz-d65", { 0.95047, 1.0, 1.08883 } }
    local white_d50 = csscolor4.xyz_d65_to_xyz_d50(white_d65)
    local white_back = csscolor4.xyz_d50_to_xyz_d65(white_d50)
    assert.same_color(white_d65, white_back, 0.000001)

    -- Test round-trip conversion for arbitrary color
    local color_d65 = { "xyz-d65", { 0.3, 0.4, 0.5 } }
    local color_d50 = csscolor4.xyz_d65_to_xyz_d50(color_d65)
    local color_back = csscolor4.xyz_d50_to_xyz_d65(color_d50)
    assert.same_color(color_d65, color_back, 0.000001)

    -- Test round-trip with alpha
    local xyz_with_alpha = { "xyz-d65", { 0.5, 0.5, 0.5 }, 0.7 }
    local xyz_d50 = csscolor4.xyz_d65_to_xyz_d50(xyz_with_alpha)
    local xyz_back = csscolor4.xyz_d50_to_xyz_d65(xyz_d50)
    assert.same_color(xyz_with_alpha, xyz_back, 0.000001)

    -- Test with "none" values
    local xyz_with_none = { "xyz-d65", { "none", 0.5, "none" } }
    local xyz_d50_none = csscolor4.xyz_d65_to_xyz_d50(xyz_with_none)
    local xyz_back_none = csscolor4.xyz_d50_to_xyz_d65(xyz_d50_none)
    -- "none" values get converted to 0, so we expect zeros
    assert.same_color({ "xyz-d65", { 0, 0.5, 0 } }, xyz_back_none, 0.000001)
  end)
end)

describe("get_conversions", function()
  ---@type colorspace[]
  local colorspaces = {
    "rgb",
    "hsl",
    "hwb",
    "lab",
    "lch",
    "oklab",
    "oklch",
    "srgb",
    "srgb-linear",
    "display-p3",
    "display-p3-linear",
    "a98-rgb",
    "a98-rgb-linear",
    "prophoto-rgb",
    "prophoto-rgb-linear",
    "rec2020",
    "rec2020-linear",
    "xyz",
    "xyz-d50",
    "xyz-d65",
  }

  it("should return empty list for same colorspace", function()
    for _, space in ipairs(colorspaces) do
      local conversions = csscolor4.get_conversions(space, space)
      assert.same({}, conversions)
    end
  end)

  it("should find direct conversions", function()
    -- RGB family direct conversions
    local rgb_to_srgb = csscolor4.get_conversions("rgb", "srgb")
    assert.same(1, #rgb_to_srgb)
    assert.same("rgb", rgb_to_srgb[1][1])
    assert.same("srgb", rgb_to_srgb[1][2])

    local srgb_to_hsl = csscolor4.get_conversions("srgb", "hsl")
    assert.same(1, #srgb_to_hsl)
    assert.same("srgb", srgb_to_hsl[1][1])
    assert.same("hsl", srgb_to_hsl[1][2])

    -- Lab family
    local lab_to_lch = csscolor4.get_conversions("lab", "lch")
    assert.same(1, #lab_to_lch)
    assert.same("lab", lab_to_lch[1][1])
    assert.same("lch", lab_to_lch[1][2])

    -- OKLab family
    local oklab_to_oklch = csscolor4.get_conversions("oklab", "oklch")
    assert.same(1, #oklab_to_oklch)
    assert.same("oklab", oklab_to_oklch[1][1])
    assert.same("oklch", oklab_to_oklch[1][2])
  end)

  it("should find multi-step conversions through xyz hubs", function()
    -- RGB to Lab should go: rgb -> srgb -> srgb-linear -> xyz-d65 -> xyz-d50 -> lab
    local rgb_to_lab = csscolor4.get_conversions("rgb", "lab")
    assert.same(5, #rgb_to_lab)
    assert.same("rgb", rgb_to_lab[1][1])
    assert.same("srgb", rgb_to_lab[1][2])
    assert.same("srgb", rgb_to_lab[2][1])
    assert.same("srgb-linear", rgb_to_lab[2][2])
    assert.same("srgb-linear", rgb_to_lab[3][1])
    assert.same("xyz-d65", rgb_to_lab[3][2])
    assert.same("xyz-d65", rgb_to_lab[4][1])
    assert.same("xyz-d50", rgb_to_lab[4][2])
    assert.same("xyz-d50", rgb_to_lab[5][1])
    assert.same("lab", rgb_to_lab[5][2])

    -- Display P3 to OKLab should go: display-p3 -> display-p3-linear -> xyz-d65 -> oklab
    local p3_to_oklab = csscolor4.get_conversions("display-p3", "oklab")
    assert.same(3, #p3_to_oklab)
    assert.same("display-p3", p3_to_oklab[1][1])
    assert.same("display-p3-linear", p3_to_oklab[1][2])
    assert.same("display-p3-linear", p3_to_oklab[2][1])
    assert.same("xyz-d65", p3_to_oklab[2][2])
    assert.same("xyz-d65", p3_to_oklab[3][1])
    assert.same("oklab", p3_to_oklab[3][2])
  end)

  it("should find conversions between all supported colorspace pairs", function()
    -- Test every combination to ensure connectivity
    for _, from_space in ipairs(colorspaces) do
      for _, to_space in ipairs(colorspaces) do
        if from_space ~= to_space then
          local conversions = csscolor4.get_conversions(from_space, to_space)
          assert.is_true(#conversions > 0)

          -- Validate conversion chain
          assert.same(from_space, conversions[1][1])
          assert.same(to_space, conversions[#conversions][2])

          -- Verify chain continuity
          for i = 1, #conversions - 1 do
            assert.same(conversions[i][2], conversions[i + 1][1])
          end
        end
      end
    end
  end)

  it("should return functions that can be called", function()
    local conversions = csscolor4.get_conversions("rgb", "srgb")
    assert.same("function", type(conversions[1][3]))

    -- Test that the function actually works
    local test_color = { "rgb", { 255, 128, 64 } }
    local result = conversions[1][3](test_color)
    assert.same("srgb", result[1])
  end)

  it("should find shortest paths", function()
    -- HSL to HWB should go through sRGB (2 steps), not through XYZ (longer)
    local hsl_to_hwb = csscolor4.get_conversions("hsl", "hwb")
    assert.same(2, #hsl_to_hwb)
    assert.same("hsl", hsl_to_hwb[1][1])
    assert.same("srgb", hsl_to_hwb[1][2])
    assert.same("srgb", hsl_to_hwb[2][1])
    assert.same("hwb", hsl_to_hwb[2][2])

    -- XYZ to XYZ-D65 should be direct (1 step)
    local xyz_to_xyz_d65 = csscolor4.get_conversions("xyz", "xyz-d65")
    assert.same(1, #xyz_to_xyz_d65)
  end)

  it("should handle conversions between different RGB spaces", function()
    -- sRGB to Display P3
    local srgb_to_p3 = csscolor4.get_conversions("srgb", "display-p3")
    assert.same(4, #srgb_to_p3)
    assert.same("srgb", srgb_to_p3[1][1])
    assert.same("srgb-linear", srgb_to_p3[1][2])
    assert.same("srgb-linear", srgb_to_p3[2][1])
    assert.same("xyz-d65", srgb_to_p3[2][2])
    assert.same("xyz-d65", srgb_to_p3[3][1])
    assert.same("display-p3-linear", srgb_to_p3[3][2])
    assert.same("display-p3-linear", srgb_to_p3[4][1])
    assert.same("display-p3", srgb_to_p3[4][2])

    -- ProPhoto RGB to Rec2020
    local prophoto_to_rec2020 = csscolor4.get_conversions("prophoto-rgb", "rec2020")
    assert.is_true(#prophoto_to_rec2020 > 2) -- Should go through XYZ
  end)

  it("should handle conversions between Lab and OKLab families", function()
    -- Lab to OKLab should go: lab -> xyz-d50 -> xyz-d65 -> oklab
    local lab_to_oklab = csscolor4.get_conversions("lab", "oklab")
    assert.same(3, #lab_to_oklab)
    assert.same("lab", lab_to_oklab[1][1])
    assert.same("xyz-d50", lab_to_oklab[1][2])
    assert.same("xyz-d50", lab_to_oklab[2][1])
    assert.same("xyz-d65", lab_to_oklab[2][2])
    assert.same("xyz-d65", lab_to_oklab[3][1])
    assert.same("oklab", lab_to_oklab[3][2])

    -- LCH to OKLCH should go through Lab and OKLab
    local lch_to_oklch = csscolor4.get_conversions("lch", "oklch")
    assert.same(5, #lch_to_oklch)
    assert.same("lch", lch_to_oklch[1][1])
    assert.same("lab", lch_to_oklch[1][2])
    assert.same("lab", lch_to_oklch[2][1])
    assert.same("xyz-d50", lch_to_oklch[2][2])
    assert.same("xyz-d50", lch_to_oklch[3][1])
    assert.same("xyz-d65", lch_to_oklch[3][2])
    assert.same("xyz-d65", lch_to_oklch[4][1])
    assert.same("oklab", lch_to_oklch[4][2])
    assert.same("oklab", lch_to_oklch[5][1])
    assert.same("oklch", lch_to_oklch[5][2])
  end)
end)

describe("convert_color_to_colorspace", function()
  it("should handle identity conversion (same colorspace)", function()
    local red_srgb = { "srgb", { 1, 0, 0 }, nil }
    local result = csscolor4.convert_color_to_colorspace(red_srgb, "srgb")
    assert.same_color(red_srgb, result)
  end)

  describe("RGB family conversions", function()
    it("should convert RGB to sRGB", function()
      local red_rgb = { "rgb", { 255, 0, 0 }, nil }
      local expected = { "srgb", { 1, 0, 0 }, nil }
      local result = csscolor4.convert_color_to_colorspace(red_rgb, "srgb")
      assert.same_color(expected, result)
    end)

    it("should convert sRGB to RGB", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local expected = { "rgb", { 255, 0, 0 }, nil }
      local result = csscolor4.convert_color_to_colorspace(red_srgb, "rgb")
      assert.same_color(expected, result)
    end)

    it("should convert sRGB to HSL and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local hsl_result = csscolor4.convert_color_to_colorspace(red_srgb, "hsl")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(hsl_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to HWB and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local hwb_result = csscolor4.convert_color_to_colorspace(red_srgb, "hwb")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(hwb_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to sRGB-linear and back", function()
      local gray_srgb = { "srgb", { 0.5, 0.5, 0.5 }, nil }
      local linear_result = csscolor4.convert_color_to_colorspace(gray_srgb, "srgb-linear")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(linear_result, "srgb")
      assert.same_color(gray_srgb, back_to_srgb, 0.0001)
    end)
  end)

  describe("Wide gamut RGB conversions", function()
    it("should convert sRGB to Display P3 and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local p3_result = csscolor4.convert_color_to_colorspace(red_srgb, "display-p3")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(p3_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to A98 RGB and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local a98_result = csscolor4.convert_color_to_colorspace(red_srgb, "a98-rgb")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(a98_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to ProPhoto RGB and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local prophoto_result = csscolor4.convert_color_to_colorspace(red_srgb, "prophoto-rgb")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(prophoto_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to Rec2020 and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local rec2020_result = csscolor4.convert_color_to_colorspace(red_srgb, "rec2020")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(rec2020_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)
  end)

  describe("Lab family conversions", function()
    it("should convert sRGB to Lab and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local lab_result = csscolor4.convert_color_to_colorspace(red_srgb, "lab")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(lab_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to LCH and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local lch_result = csscolor4.convert_color_to_colorspace(red_srgb, "lch")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(lch_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert Lab to LCH and back", function()
      local red_lab = { "lab", { 53.24, 80.09, 67.20 }, nil }
      local lch_result = csscolor4.convert_color_to_colorspace(red_lab, "lch")
      local back_to_lab = csscolor4.convert_color_to_colorspace(lch_result, "lab")
      assert.same_color(red_lab, back_to_lab, 0.0001)
    end)
  end)

  describe("OKLab family conversions", function()
    it("should convert sRGB to OKLab and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local oklab_result = csscolor4.convert_color_to_colorspace(red_srgb, "oklab")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(oklab_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to OKLCH and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local oklch_result = csscolor4.convert_color_to_colorspace(red_srgb, "oklch")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(oklch_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert OKLab to OKLCH and back", function()
      local red_oklab = { "oklab", { 0.628, 0.225, 0.126 }, nil }
      local oklch_result = csscolor4.convert_color_to_colorspace(red_oklab, "oklch")
      local back_to_oklab = csscolor4.convert_color_to_colorspace(oklch_result, "oklab")
      assert.same_color(red_oklab, back_to_oklab, 0.0001)
    end)
  end)

  describe("XYZ family conversions", function()
    it("should convert sRGB to XYZ and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local xyz_result = csscolor4.convert_color_to_colorspace(red_srgb, "xyz")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(xyz_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to XYZ-D65 and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local xyz_d65_result = csscolor4.convert_color_to_colorspace(red_srgb, "xyz-d65")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(xyz_d65_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert sRGB to XYZ-D50 and back", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local xyz_d50_result = csscolor4.convert_color_to_colorspace(red_srgb, "xyz-d50")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(xyz_d50_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.0001)
    end)

    it("should convert XYZ-D65 to XYZ-D50 and back", function()
      local white_xyz_d65 = { "xyz-d65", { 0.95047, 1.0, 1.08883 }, nil }
      local xyz_d50_result = csscolor4.convert_color_to_colorspace(white_xyz_d65, "xyz-d50")
      local back_to_xyz_d65 = csscolor4.convert_color_to_colorspace(xyz_d50_result, "xyz-d65")
      assert.same_color(white_xyz_d65, back_to_xyz_d65, 0.0001)
    end)
  end)

  describe("Cross-family conversions", function()
    it("should convert Lab to OKLab and back", function()
      local red_lab = { "lab", { 53.24, 80.09, 67.20 }, nil }
      local oklab_result = csscolor4.convert_color_to_colorspace(red_lab, "oklab")
      local back_to_lab = csscolor4.convert_color_to_colorspace(oklab_result, "lab")
      assert.same_color(red_lab, back_to_lab, 0.001)
    end)

    it("should convert LCH to OKLCH and back", function()
      local red_lch = { "lch", { 53.24, 104.55, 40.00 }, nil }
      local oklch_result = csscolor4.convert_color_to_colorspace(red_lch, "oklch")
      local back_to_lch = csscolor4.convert_color_to_colorspace(oklch_result, "lch")
      assert.same_color(red_lch, back_to_lch, 0.001)
    end)

    it("should convert between different RGB gamuts", function()
      local red_srgb = { "srgb", { 1, 0, 0 }, nil }
      local p3_result = csscolor4.convert_color_to_colorspace(red_srgb, "display-p3")
      local a98_result = csscolor4.convert_color_to_colorspace(p3_result, "a98-rgb")
      local prophoto_result = csscolor4.convert_color_to_colorspace(a98_result, "prophoto-rgb")
      local rec2020_result = csscolor4.convert_color_to_colorspace(prophoto_result, "rec2020")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(rec2020_result, "srgb")
      assert.same_color(red_srgb, back_to_srgb, 0.001)
    end)
  end)

  describe("Alpha preservation", function()
    it("should preserve alpha channel through conversions", function()
      local red_srgb_alpha = { "srgb", { 1, 0, 0 }, 0.5 }
      local lab_result = csscolor4.convert_color_to_colorspace(red_srgb_alpha, "lab")
      assert.same(0.5, lab_result[3])

      local back_to_srgb = csscolor4.convert_color_to_colorspace(lab_result, "srgb")
      assert.same_color(red_srgb_alpha, back_to_srgb, 0.0001)
    end)

    it("should preserve 'none' alpha values", function()
      local red_srgb_none = { "srgb", { 1, 0, 0 }, "none" }
      local oklch_result = csscolor4.convert_color_to_colorspace(red_srgb_none, "oklch")
      assert.same("none", oklch_result[3])

      local back_to_srgb = csscolor4.convert_color_to_colorspace(oklch_result, "srgb")
      assert.same_color(red_srgb_none, back_to_srgb, 0.0001)
    end)
  end)

  describe("Edge cases", function()
    it("should handle black color conversions", function()
      local black_srgb = { "srgb", { 0, 0, 0 }, nil }
      local lab_result = csscolor4.convert_color_to_colorspace(black_srgb, "lab")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(lab_result, "srgb")
      assert.same_color(black_srgb, back_to_srgb, 0.0001)
    end)

    it("should handle white color conversions", function()
      local white_srgb = { "srgb", { 1, 1, 1 }, nil }
      local oklab_result = csscolor4.convert_color_to_colorspace(white_srgb, "oklab")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(oklab_result, "srgb")
      assert.same_color(white_srgb, back_to_srgb, 0.0001)
    end)

    it("should handle gray color conversions", function()
      local gray_srgb = { "srgb", { 0.5, 0.5, 0.5 }, nil }
      local hsl_result = csscolor4.convert_color_to_colorspace(gray_srgb, "hsl")
      local lch_result = csscolor4.convert_color_to_colorspace(hsl_result, "lch")
      local back_to_srgb = csscolor4.convert_color_to_colorspace(lch_result, "srgb")
      assert.same_color(gray_srgb, back_to_srgb, 0.001)
    end)
  end)
end)
