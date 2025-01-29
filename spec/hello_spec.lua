local hello = require("nvim-colors.hello")

describe("a test", function()
  it("works", function()
    assert.are_equal(hello.add(1, 2), 3)
  end)
end)
