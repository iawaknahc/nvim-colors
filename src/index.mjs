import {
  parse,
  serialize,
  to,
  contrastAPCA,
  // ColorSpace registry.
  ColorSpace,
  // The following are color spaces.
  XYZ_D65,
  XYZ_D50,
  XYZ_ABS_D65,
  Lab_D65,
  Lab,
  LCH,
  sRGB_Linear,
  sRGB,
  HSL,
  HWB,
  HSV,
  P3_Linear,
  P3,
  A98RGB_Linear,
  A98RGB,
  ProPhoto_Linear,
  ProPhoto,
  REC_2020_Linear,
  REC_2020,
  OKLab,
  OKLCH,
  OKLrab,
  OKLrCH,
  Okhsl,
  Okhsv,
  CAM16_JMh,
  HCT,
  Luv,
  LCHuv,
  HSLuv,
  HPLuv,
  Jzazbz,
  JzCzHz,
  ICTCP,
  REC_2100_Linear,
  REC_2100_PQ,
  REC_2100_HLG,
  ACEScg,
  ACEScc,
} from "colorjs.io/fn";

ColorSpace.register(XYZ_D65);
ColorSpace.register(XYZ_D50);
ColorSpace.register(XYZ_ABS_D65);
ColorSpace.register(Lab_D65);
ColorSpace.register(Lab);
ColorSpace.register(LCH);
ColorSpace.register(sRGB_Linear);
ColorSpace.register(sRGB);
ColorSpace.register(HSL);
ColorSpace.register(HWB);
ColorSpace.register(HSV);
ColorSpace.register(P3_Linear);
ColorSpace.register(P3);
ColorSpace.register(A98RGB_Linear);
ColorSpace.register(A98RGB);
ColorSpace.register(ProPhoto_Linear);
ColorSpace.register(ProPhoto);
ColorSpace.register(REC_2020_Linear);
ColorSpace.register(REC_2020);
ColorSpace.register(OKLab);
ColorSpace.register(OKLCH);
ColorSpace.register(OKLrab);
ColorSpace.register(OKLrCH);
ColorSpace.register(Okhsl);
ColorSpace.register(Okhsv);
ColorSpace.register(CAM16_JMh);
ColorSpace.register(HCT);
ColorSpace.register(Luv);
ColorSpace.register(LCHuv);
ColorSpace.register(HSLuv);
ColorSpace.register(HPLuv);
ColorSpace.register(Jzazbz);
ColorSpace.register(JzCzHz);
ColorSpace.register(ICTCP);
ColorSpace.register(REC_2100_Linear);
ColorSpace.register(REC_2100_PQ);
ColorSpace.register(REC_2100_HLG);
ColorSpace.register(ACEScg);
ColorSpace.register(ACEScc);

/**
 * @param a {import("colorjs.io/fn").PlainColorObject}
 * @returns string
 */
function colorToNvim(a) {
  const b = to(a, "srgb");
  // Make sure the color is opaque.
  b.alpha = 1;
  return serialize(b, {
    format: "hex",
    // Need collapse=false to always have 6 digits.
    // https://github.com/color-js/color.js/issues/266
    collapse: false,
  });
}

// Alpha blending is not supported in colorjs.io.
// But there is a draft PR https://github.com/color-js/color.js/pull/231/files
/**
 * @param source {import("colorjs.io/fn").ColorConstructor}
 * @param backdrop {import("colorjs.io/fn").ColorConstructor}
 * @returns import("colorjs.io/fn").PlainColorObject
 */
function over(source, backdrop) {
  let result;

  if (source.alpha === 0) {
    result = backdrop;
  } else if (source.alpha === 1 || backdrop.alpha === 0) {
    result = source;
  } else {
    let source_xyz = to(source, XYZ_D65);
    let backdrop_xyz = to(backdrop, XYZ_D65);

    result = {
      spaceId: XYZ_D65.id,
      coords: source_xyz.coords.map((s, i) => {
        if (s == null) {
          s = 0;
        }

        let b = backdrop_xyz.coords[i];
        if (b == null) {
          b = 0;
        }

        // https://www.w3.org/TR/compositing/#simplealphacompositing
        return s * source.alpha + b * backdrop.alpha * (1 - source.alpha);
      }),
      // https://www.w3.org/TR/compositing/#simplealphacompositing
      alpha: source.alpha + backdrop.alpha * (1 - source.alpha),
    };
  }

  return to(result, source.spaceId);
}

function NvimColorsConvertCSSColorForHighlight({
  // color is the color we are going to highlight.
  color,

  // alpha is used to set the alpha of color.
  // It is optional.
  // The valid value is [0, 1].
  alpha,

  // fg_color and bg_color are the foreground color and background color respectively.
  // They are used to determine the foreground color given that the color being the background color.
  // We use APCA contrast to ensure the foreground color is easy to read.
  fg_color,
  bg_color,
}) {
  try {
    let c = parse(color);
    if (alpha != null && typeof alpha === "number") {
      c.alpha = Math.max(0, Math.min(1, alpha));
    }

    const fg = parse(fg_color);
    const bg = parse(bg_color);

    c = over(c, bg);

    const contrast_with_fg = Math.abs(contrastAPCA(c, fg));
    const contrast_with_bg = Math.abs(contrastAPCA(c, bg));

    return {
      contrast_with_fg,
      contrast_with_bg,
      highlight_bg: colorToNvim(c),
      highlight_fg:
        contrast_with_fg < contrast_with_bg ? colorToNvim(bg) : colorToNvim(fg),
    };
  } catch (e) {
    return "";
  }
}

export default function (plugin) {
  plugin.registerFunction(
    "NvimColorsConvertCSSColorForHighlight",
    async (args) => {
      const input = args[0];
      return NvimColorsConvertCSSColorForHighlight(input);
    },
    { sync: true },
  );
}
