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

function base10ToColor(base10) {
  if (base10 == null) {
    return null;
  }

  const hex6 = "#" + ("000000" + base10.toString(16)).slice(-6);
  return parse(hex6);
}

function NvimColorsConvertCSSColorForHighlight({
  css_color,
  fg_base10,
  bg_base10,
}) {
  const fg = base10ToColor(fg_base10);
  const bg = base10ToColor(bg_base10);

  try {
    const color_with_alpha_in_unknown_space = parse(css_color);
    const canonical = serialize(color_with_alpha_in_unknown_space);
    const color_with_alpha_in_srgb = to(
      color_with_alpha_in_unknown_space,
      "srgb",
    );

    // FIXME: take the terminal background color and perform alpha blending.
    // https://github.com/color-js/color.js/issues/230
    color_with_alpha_in_srgb.alpha = 1;

    // Need collapse=false to always have 6 digits.
    // https://github.com/color-js/color.js/issues/266
    const hex6 = serialize(color_with_alpha_in_srgb, {
      format: "hex",
      collapse: false,
    });

    const output = {
      canonical,
      hex6,
    };

    if (fg != null && bg != null) {
      const contrast_with_fg = Math.abs(
        contrastAPCA(color_with_alpha_in_srgb, fg),
      );
      const contrast_with_bg = Math.abs(
        contrastAPCA(color_with_alpha_in_srgb, bg),
      );
      output.contrast_with_fg = contrast_with_fg;
      output.contrast_with_bg = contrast_with_bg;

      if (contrast_with_fg < contrast_with_bg) {
        output.fg = serialize(bg, {
          format: "hex",
          collapse: false,
        });
      } else {
        output.fg = serialize(fg, {
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
