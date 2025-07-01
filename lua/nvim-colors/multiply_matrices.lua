--- Translation of https://www.w3.org/TR/css-color-4/multiply-matrices.js
--- Vector is in column-major order.
---
--- @param A number[][]|number[]
--- @param B number[][]|number[]
--- @return number[][]|number[]
local function multiply_matrices(A, B)
  -- Convert vector A to matrix
  if type(A[1]) == "number" then
    A = { A }
  end
  local m = #A

  -- Convert vector B to matrix
  if type(B[1]) == "number" then
    local B_matrix = {}
    for i = 1, #B do
      B_matrix[i] = { B[i] }
    end
    B = B_matrix
  end
  local p = #B[1]

  -- Transpose B
  local B_cols = {}
  for i = 1, p do
    B_cols[i] = {}
    for j = 1, #B do
      B_cols[i][j] = B[j][i]
    end
  end

  -- Multiply matrices
  local product = {}
  for i = 1, #A do
    product[i] = {}
    for j = 1, #B_cols do
      local sum = 0
      for k = 1, #A[i] do
        sum = sum + A[i][k] * (B_cols[j][k] or 0)
      end
      product[i][j] = sum
    end
  end

  -- Return single row as vector
  if m == 1 then
    product = product[1]
  end

  -- Return single column as vector
  if p == 1 then
    local result = {}
    for i = 1, #product do
      if type(product[i]) == "table" then
        result[i] = product[i][1]
      else
        result[i] = product[i]
      end
    end
    return result
  end

  return product
end

return multiply_matrices
