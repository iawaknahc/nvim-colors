const Color = require("colorjs.io").default;

describe("Color", () => {
  it("should treat none case-insensitively, but it does not", () => {
    expect((new Color("RGB(None none none)")).toString({format: "hex", collapse: false})).toEqual("#NaNNaNNaN");
    expect(new Color("RGB(none none none)").toString({format: "hex", collapse: false})).toEqual("#000000");
  })
});
