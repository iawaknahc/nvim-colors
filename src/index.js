// v0.5.2 serializes none to NaN.
// So we use v0.6.0-alpha.1 instead.
// See https://github.com/color-js/color.js/pull/476
const Color = require("colorjs.io").default;

function base10ToColor(base10) {
  if (base10 == null) {
    return null;
  }

  const hex6 = "#" + ("000000" + base10.toString(16)).slice(-6);
  return new Color(hex6);
}

function NvimColorsConvertCSSColorForHighlight({
  css_color,
  fg_base10,
  bg_base10,
}) {
  const fg = base10ToColor(fg_base10);
  const bg = base10ToColor(bg_base10);

  try {
    const color_with_alpha_in_unknown_space = new Color(css_color);
    const canonical = color_with_alpha_in_unknown_space.toString();
    const color_with_alpha_in_srgb =
      color_with_alpha_in_unknown_space.to("srgb");

    // FIXME: take the terminal background color and perform alpha blending.
    // https://github.com/color-js/color.js/issues/230
    color_with_alpha_in_srgb.alpha = 1;

    // Need collapse=false to always have 6 digits.
    // https://github.com/color-js/color.js/issues/266
    const hex6 = color_with_alpha_in_srgb.toString({
      format: "hex",
      collapse: false,
    });

    const output = {
      canonical,
      hex6,
    };

    if (fg != null && bg != null) {
      const contrast_with_fg = Math.abs(
        Color.contrastAPCA(color_with_alpha_in_srgb, fg),
      );
      const contrast_with_bg = Math.abs(
        Color.contrastAPCA(color_with_alpha_in_srgb, bg),
      );
      output.contrast_with_fg = contrast_with_fg;
      output.contrast_with_bg = contrast_with_bg;

      if (contrast_with_fg < contrast_with_bg) {
        output.fg = bg.toString({
          format: "hex",
          collapse: false,
        });
      } else {
        output.fg = fg.toString({
          format: "hex",
          collapse: false,
        });
      }
    }

    return output;
  } catch (e) {
    return "";
  }
}

module.exports = (plugin) => {
  plugin.registerFunction(
    "NvimColorsConvertCSSColorForHighlight",
    async (args) => {
      const input = args[0];
      return NvimColorsConvertCSSColorForHighlight(input);
    },
    { sync: true },
  );
};
