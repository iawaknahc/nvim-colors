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

function srgbWithAlphaStripped(str) {
  const a = parse(str);
  const b = to(a, "srgb");
  // FIXME: take the terminal background color and perform alpha blending.
  // https://github.com/color-js/color.js/issues/230
  b.alpha = 1;
  return b;
}

function colorToNvim(a) {
  const b = to(a, "srgb");
  // Need collapse=false to always have 6 digits.
  // https://github.com/color-js/color.js/issues/266
  return serialize(b, {
    format: "hex",
    collapse: false,
  });
}

function NvimColorsConvertCSSColorForHighlight({
  // color is the color we are going to highlight.
  color,
  // fg_color and bg_color are the foreground color and background color respectively.
  // They are used to determine the foreground color given that the color being the background color.
  // We use APCA contrast to ensure the foreground color is easy to read.
  fg_color,
  bg_color,
}) {
  try {
    const c = srgbWithAlphaStripped(color);
    const fg = srgbWithAlphaStripped(fg_color);
    const bg = srgbWithAlphaStripped(bg_color);

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
