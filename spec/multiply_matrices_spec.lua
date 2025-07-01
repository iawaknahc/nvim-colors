local multiply_matrices = require("nvim-colors.multiply_matrices")

describe("multiply_matrices", function()
  it("matrix x matrix", function()
    local A = {
      { 1, 2, 3 },
      { 4, 5, 6 },
    }
    local B = {
      { 7, 8 },
      { 9, 10 },
      { 11, 12 },
    }
    local expected = {
      { 58, 64 },
      { 139, 154 },
    }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("matrix x vector", function()
    local A = {
      { 1, 2, 3 },
      { 4, 5, 6 },
    }
    --
    local B = { 7, 8, 9 }
    local expected = { 50, 122 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("vector x matrix", function()
    local A = { 1, 2 }
    local B = {
      { 3, 4, 5 },
      { 6, 7, 8 },
    }
    local expected = { 15, 18, 21 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("vector x vector (column)", function()
    local A = { 1, 2, 3 }
    local B = { 4, 5, 6 }
    local expected = { 32 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("3x3 identity matrix", function()
    local A = {
      { 1, 0, 0 },
      { 0, 1, 0 },
      { 0, 0, 1 },
    }
    local B = { 5, 10, 15 }
    local expected = { 5, 10, 15 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("zero matrix", function()
    local A = {
      { 0, 0 },
      { 0, 0 },
    }
    local B = { 5, 10 }
    local expected = { 0, 0 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("single element matrix", function()
    local A = { { 5 } }
    local B = { { 3 } }
    local expected = { 15 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("negative values", function()
    local A = {
      { -1, 2 },
      { 3, -4 },
    }
    local B = { 5, -6 }
    local expected = { -17, 39 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("fractional values", function()
    local A = {
      { 0.5, 0.25 },
      { 0.75, 0.125 },
    }
    local B = { 4, 8 }
    local expected = { 4, 4 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)

  it("rectangular matrices", function()
    local A = {
      { 1, 2, 3, 4 },
    }
    local B = {
      { 5 },
      { 6 },
      { 7 },
      { 8 },
    }
    local expected = { 70 }

    local result = multiply_matrices(A, B)
    assert.same(expected, result)
  end)
end)
