/**
 * @file Colors grammar for tree-sitter
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

// The printable symbols in ASCII.
const SYMBOLS = [
  "!", // 0x21
  '"', // 0x22
  "#", // 0x23
  "$", // 0x24
  "%", // 0x25
  "&", // 0x26
  "'", // 0x27
  "(", // 0x28
  ")", // 0x29
  "*", // 0x2a
  "+", // 0x2b
  ",", // 0x2c
  ".", // 0x2e
  "/", // 0x2f

  ":", // 0x3a
  ";", // 0x3b
  "<", // 0x3c
  "=", // 0x3d
  ">", // 0x3e
  "?", // 0x3f
  "@", // 0x40

  "[", // 0x5b
  "\\", // 0x5c
  "]", // 0x5d
  "^", // 0x5e
  "`", // 0x60

  "{", // 0x7b
  "|", // 0x7c
  "}", // 0x7d
  "~", // 0x7e

  // These two symbols are not included because they are identifier characters
  // in many languages.
  // "_", // 0x5f
  // "-", // 0x2d
];

/**
 * @param literal {string}
 * @returns {RegExp}
 */
function css_keyword(literal) {
  return new RegExp(literal, "i");
}

function rgb_legacy_percentage($, functionName) {
  return seq(
    field("function_name", functionName),
    field("r", $.css_percentage),
    ",",
    field("g", $.css_percentage),
    ",",
    field("b", $.css_percentage),
    optional(seq(",", field("alpha", $.css_alpha_value))),
    ")",
  );
}

function rgb_legacy_number($, functionName) {
  return seq(
    field("function_name", functionName),
    field("r", $.css_number),
    ",",
    field("g", $.css_number),
    ",",
    field("b", $.css_number),
    optional(seq(",", field("alpha", $.css_alpha_value))),
    ")",
  );
}

function rgb_modern($, functionName) {
  return seq(
    field("function_name", functionName),
    field("r", choice($.css_number, $.css_percentage, $.css_keyword_none)),
    field("g", choice($.css_number, $.css_percentage, $.css_keyword_none)),
    field("b", choice($.css_number, $.css_percentage, $.css_keyword_none)),
    optional(
      seq("/", field("alpha", choice($.css_alpha_value, $.css_keyword_none))),
    ),
    ")",
  );
}

function hsl_legacy($, functionName) {
  return seq(
    field("function_name", functionName),
    field("h", $.css_hue),
    ",",
    field("s", $.css_percentage),
    ",",
    field("l", $.css_percentage),
    optional(seq(",", field("alpha", $.css_alpha_value))),
    ")",
  );
}

function h_modern($, functionName, fieldA, fieldB) {
  return seq(
    field("function_name", functionName),
    field("h", choice($.css_hue, $.css_keyword_none)),
    field(fieldA, choice($.css_percentage, $.css_number, $.css_keyword_none)),
    field(fieldB, choice($.css_percentage, $.css_number, $.css_keyword_none)),
    optional(
      seq("/", field("alpha", choice($.css_alpha_value, $.css_keyword_none))),
    ),
    ")",
  );
}

function lab($, functionName) {
  return seq(
    field("function_name", functionName),
    field("L", choice($.css_percentage, $.css_number, $.css_keyword_none)),
    field("a", choice($.css_percentage, $.css_number, $.css_keyword_none)),
    field("b", choice($.css_percentage, $.css_number, $.css_keyword_none)),
    optional(
      seq("/", field("alpha", choice($.css_alpha_value, $.css_keyword_none))),
    ),
    ")",
  );
}

function lch($, functionName) {
  return seq(
    field("function_name", functionName),
    field("L", choice($.css_percentage, $.css_number, $.css_keyword_none)),
    field("C", choice($.css_percentage, $.css_number, $.css_keyword_none)),
    field("h", choice($.css_hue, $.css_keyword_none)),
    optional(
      seq("/", field("alpha", choice($.css_alpha_value, $.css_keyword_none))),
    ),
    ")",
  );
}

/**
 * @param a {RegExp}
 * @param b {RegExp}
 * @param [flags] {"i"}
 * @returns {RegExp}
 */
function concat_regexp(a, b, flags) {
  return new RegExp("(?:" + a.source + ")" + "(?:" + b.source + ")", flags);
}

// Taken from https://github.com/stsewd/tree-sitter-comment/blob/3555706cef8b98d3e4c7379d7260548ff03ad363/grammar.js#L114
/**
 * @param string {string}
 * @returns {string}
 */
function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

const SYMBOLS_STRING = escapeRegExp(SYMBOLS.join(""));
const symbol = new RegExp(`[${SYMBOLS_STRING}]`);
const non_symbol = new RegExp(`[^ \\t\\n\\r${SYMBOLS_STRING}]+`);
const non_whitespace = new RegExp(`[^ \\t\\n\\r]`);

const css_number = /[-+]?(?:\d+\.\d+|\d+|\.\d+)(?:[eE][-+]?\d+)?/;
const css_percentage = concat_regexp(css_number, /%/);
const css_angle = concat_regexp(css_number, /deg|grad|rad|turn/, "i");

const tailwindcss_color_name = /[_a-zA-Z0-9][-_a-zA-Z0-9]*/;

const tailwindcss_color_utility =
  /bg|text|decoration|border|outline|shadow|inset-shadow|ring|inset-ring|accent|caret|fill|stroke|from|via|to/;

module.exports = grammar({
  // This name is important, it defines the exported C function name.
  name: "nvimcolors",

  word: ($) => $.non_whitespace,

  rules: {
    source_file: ($) =>
      repeat(
        choice(
          // https://www.w3.org/TR/css-color-4/#color-syntax
          $.css_color,

          // https://developer.android.com/reference/android/graphics/Color#encoding
          // https://api.flutter.dev/flutter/dart-ui/Color-class.html
          $.u32_argb,

          $.tailwindcss_color,

          $._css_hex_color_invalid,
          $._non_symbol,
          $._symbol,
        ),
      ),

    // In preparation for CSS Color Level 5, where CSS color becomes recursive.
    css_color: ($) =>
      choice(
        $.css_hex_color,
        $.css_named_color,
        $.css_keyword_transparent,
        $.css_function_rgb,
        $.css_function_rgba,
        $.css_function_hsl,
        $.css_function_hsla,
        $.css_function_hwb,
        $.css_function_lab,
        $.css_function_oklab,
        $.css_function_lch,
        $.css_function_oklch,
        $.css_function_color,
      ),

    // https://www.w3.org/TR/css-syntax-3/#number-token-diagram
    _css_number: (_) => css_number,
    css_number: ($) => $._css_number,

    // https://www.w3.org/TR/css-syntax-3/#percentage-token-diagram
    _css_percentage: (_) => css_percentage,
    css_percentage: ($) => $._css_percentage,

    // https://www.w3.org/TR/css-color-4/#alpha-syntax
    css_alpha_value: ($) => choice($._css_number, $._css_percentage),

    // https://www.w3.org/TR/css-values-4/#angle-value
    // https://www.w3.org/TR/css-values-4/#typedef-dimension
    _css_angle: (_) => css_angle,
    css_angle: ($) => $._css_angle,

    // https://www.w3.org/TR/css-color-4/#typedef-hue
    css_hue: ($) => choice($._css_number, $._css_angle),

    // According to CSS grammar, there is no spaces between the function name and the opening parenthesis.
    // This can be done with token.immediate() alone.
    // We additionally wrap the sequence with token() because
    // we want to reduce parse errors when the text looks like `color: `
    // Without token(), `color: ` will be tokenized as `color` and `:`.
    // tree-sitter considers `:` as parse error because `color` is not
    // immediately followed by `(`.
    // With token(), the color function rule will be considered only when
    // `color(` is tokenized.
    // This can reduce parse error, and hence make parsing faster.
    // The caveat is that the field "function_name" now includes
    // the opening parenthesis at the end.
    // I cannot figure out how to work around that.
    // But this is a very minor issue comparing to the degraded parsing
    // performance in a CSS file containing a lot of occurrences of `color: `
    css_function_name_rgb: (_) =>
      token(seq(css_keyword("rgb"), token.immediate("("))),
    css_function_name_rgba: (_) =>
      token(seq(css_keyword("rgba"), token.immediate("("))),
    css_function_name_hsl: (_) =>
      token(seq(css_keyword("hsl"), token.immediate("("))),
    css_function_name_hsla: (_) =>
      token(seq(css_keyword("hsla"), token.immediate("("))),
    css_function_name_hwb: (_) =>
      token(seq(css_keyword("hwb"), token.immediate("("))),
    css_function_name_lab: (_) =>
      token(seq(css_keyword("lab"), token.immediate("("))),
    css_function_name_oklab: (_) =>
      token(seq(css_keyword("oklab"), token.immediate("("))),
    css_function_name_lch: (_) =>
      token(seq(css_keyword("lch"), token.immediate("("))),
    css_function_name_oklch: (_) =>
      token(seq(css_keyword("oklch"), token.immediate("("))),
    css_function_name_color: (_) =>
      token(seq(css_keyword("color"), token.immediate("("))),

    // https://www.w3.org/TR/css-color-4/#rgb-functions
    css_function_rgb: ($) =>
      choice($._css_function_rgb_legacy, $._css_function_rgb_modern),
    css_function_rgba: ($) =>
      choice($._css_function_rgba_legacy, $._css_function_rgba_modern),
    _css_function_rgb_legacy: ($) =>
      choice(
        rgb_legacy_percentage($, $.css_function_name_rgb),
        rgb_legacy_number($, $.css_function_name_rgb),
      ),
    _css_function_rgba_legacy: ($) =>
      choice(
        rgb_legacy_percentage($, $.css_function_name_rgba),
        rgb_legacy_number($, $.css_function_name_rgba),
      ),
    _css_function_rgb_modern: ($) => rgb_modern($, $.css_function_name_rgb),
    _css_function_rgba_modern: ($) => rgb_modern($, $.css_function_name_rgba),

    // https://www.w3.org/TR/css-color-4/#the-hsl-notation
    css_function_hsl: ($) =>
      choice($._css_function_hsl_legacy, $._css_function_hsl_modern),
    _css_function_hsl_legacy: ($) => hsl_legacy($, $.css_function_name_hsl),
    _css_function_hsl_modern: ($) =>
      h_modern($, $.css_function_name_hsl, "s", "l"),
    css_function_hsla: ($) =>
      choice($._css_function_hsla_legacy, $._css_function_hsla_modern),
    _css_function_hsla_legacy: ($) => hsl_legacy($, $.css_function_name_hsla),
    _css_function_hsla_modern: ($) =>
      h_modern($, $.css_function_name_hsla, "s", "l"),

    // https://www.w3.org/TR/css-color-4/#the-hwb-notation
    css_function_hwb: ($) => h_modern($, $.css_function_name_hwb, "w", "b"),

    // https://www.w3.org/TR/css-color-4/#specifying-lab-lch
    css_function_lab: ($) => lab($, $.css_function_name_lab),
    // https://www.w3.org/TR/css-color-4/#specifying-oklab-oklch
    css_function_oklab: ($) => lab($, $.css_function_name_oklab),

    // https://www.w3.org/TR/css-color-4/#specifying-lab-lch
    css_function_lch: ($) => lch($, $.css_function_name_lch),
    // https://www.w3.org/TR/css-color-4/#specifying-oklab-oklch
    css_function_oklch: ($) => lch($, $.css_function_name_oklch),

    // https://www.w3.org/TR/css-color-4/#color-function
    css_function_color: ($) =>
      choice($.css_function_color_rgb, $.css_function_color_xyz),
    css_function_color_rgb: ($) =>
      seq(
        field("function_name", $.css_function_name_color),
        field("color_space", $.css_predefined_rgb),
        field("r", choice($.css_number, $.css_percentage, $.css_keyword_none)),
        field("g", choice($.css_number, $.css_percentage, $.css_keyword_none)),
        field("b", choice($.css_number, $.css_percentage, $.css_keyword_none)),
        optional(
          seq(
            "/",
            field("alpha", choice($.css_alpha_value, $.css_keyword_none)),
          ),
        ),
        ")",
      ),
    css_predefined_rgb: (_) =>
      choice(
        css_keyword("srgb"),
        css_keyword("srgb-linear"),
        css_keyword("display-p3"),
        css_keyword("a98-rgb"),
        css_keyword("prophoto-rgb"),
        css_keyword("rec2020"),
      ),
    css_function_color_xyz: ($) =>
      seq(
        field("function_name", $.css_function_name_color),
        field("color_space", $.css_xyz_space),
        field("x", choice($.css_number, $.css_percentage, $.css_keyword_none)),
        field("y", choice($.css_number, $.css_percentage, $.css_keyword_none)),
        field("z", choice($.css_number, $.css_percentage, $.css_keyword_none)),
        optional(
          seq(
            "/",
            field("alpha", choice($.css_alpha_value, $.css_keyword_none)),
          ),
        ),
        ")",
      ),
    css_xyz_space: (_) =>
      choice(
        css_keyword("xyz"),
        css_keyword("xyz-d50"),
        css_keyword("xyz-d65"),
      ),

    // https://www.w3.org/TR/css-color-4/#hex-notation
    css_hex_color: ($) =>
      choice(
        $._css_hex_color_8_digits,
        $._css_hex_color_6_digits,
        $._css_hex_color_4_digits,
        $._css_hex_color_3_digits,
      ),
    _css_hex_color_8_digits: (_) => /#[0-9a-fA-F]{8}/,
    _css_hex_color_6_digits: (_) => /#[0-9a-fA-F]{6}/,
    _css_hex_color_4_digits: (_) => /#[0-9a-fA-F]{4}/,
    _css_hex_color_3_digits: (_) => /#[0-9a-fA-F]{3}/,
    _css_hex_color_invalid: (_) => /#[0-9a-zA-Z]+/,

    // https://www.w3.org/TR/css-color-4/#named-colors
    css_named_color: (_) =>
      choice(
        css_keyword("aliceblue"),
        css_keyword("antiquewhite"),
        css_keyword("aqua"),
        css_keyword("aquamarine"),
        css_keyword("azure"),
        css_keyword("beige"),
        css_keyword("bisque"),
        css_keyword("black"),
        css_keyword("blanchedalmond"),
        css_keyword("blue"),
        css_keyword("blueviolet"),
        css_keyword("brown"),
        css_keyword("burlywood"),
        css_keyword("cadetblue"),
        css_keyword("chartreuse"),
        css_keyword("chocolate"),
        css_keyword("coral"),
        css_keyword("cornflowerblue"),
        css_keyword("cornsilk"),
        css_keyword("crimson"),
        css_keyword("cyan"),
        css_keyword("darkblue"),
        css_keyword("darkcyan"),
        css_keyword("darkgoldenrod"),
        css_keyword("darkgray"),
        css_keyword("darkgreen"),
        css_keyword("darkgrey"),
        css_keyword("darkkhaki"),
        css_keyword("darkmagenta"),
        css_keyword("darkolivegreen"),
        css_keyword("darkorange"),
        css_keyword("darkorchid"),
        css_keyword("darkred"),
        css_keyword("darksalmon"),
        css_keyword("darkseagreen"),
        css_keyword("darkslateblue"),
        css_keyword("darkslategray"),
        css_keyword("darkslategrey"),
        css_keyword("darkturquoise"),
        css_keyword("darkviolet"),
        css_keyword("deeppink"),
        css_keyword("deepskyblue"),
        css_keyword("dimgray"),
        css_keyword("dimgrey"),
        css_keyword("dodgerblue"),
        css_keyword("firebrick"),
        css_keyword("floralwhite"),
        css_keyword("forestgreen"),
        css_keyword("fuchsia"),
        css_keyword("gainsboro"),
        css_keyword("ghostwhite"),
        css_keyword("gold"),
        css_keyword("goldenrod"),
        css_keyword("gray"),
        css_keyword("green"),
        css_keyword("greenyellow"),
        css_keyword("grey"),
        css_keyword("honeydew"),
        css_keyword("hotpink"),
        css_keyword("indianred"),
        css_keyword("indigo"),
        css_keyword("ivory"),
        css_keyword("khaki"),
        css_keyword("lavender"),
        css_keyword("lavenderblush"),
        css_keyword("lawngreen"),
        css_keyword("lemonchiffon"),
        css_keyword("lightblue"),
        css_keyword("lightcoral"),
        css_keyword("lightcyan"),
        css_keyword("lightgoldenrodyellow"),
        css_keyword("lightgray"),
        css_keyword("lightgreen"),
        css_keyword("lightgrey"),
        css_keyword("lightpink"),
        css_keyword("lightsalmon"),
        css_keyword("lightseagreen"),
        css_keyword("lightskyblue"),
        css_keyword("lightslategray"),
        css_keyword("lightslategrey"),
        css_keyword("lightsteelblue"),
        css_keyword("lightyellow"),
        css_keyword("lime"),
        css_keyword("limegreen"),
        css_keyword("linen"),
        css_keyword("magenta"),
        css_keyword("maroon"),
        css_keyword("mediumaquamarine"),
        css_keyword("mediumblue"),
        css_keyword("mediumorchid"),
        css_keyword("mediumpurple"),
        css_keyword("mediumseagreen"),
        css_keyword("mediumslateblue"),
        css_keyword("mediumspringgreen"),
        css_keyword("mediumturquoise"),
        css_keyword("mediumvioletred"),
        css_keyword("midnightblue"),
        css_keyword("mintcream"),
        css_keyword("mistyrose"),
        css_keyword("moccasin"),
        css_keyword("navajowhite"),
        css_keyword("navy"),
        css_keyword("oldlace"),
        css_keyword("olive"),
        css_keyword("olivedrab"),
        css_keyword("orange"),
        css_keyword("orangered"),
        css_keyword("orchid"),
        css_keyword("palegoldenrod"),
        css_keyword("palegreen"),
        css_keyword("paleturquoise"),
        css_keyword("palevioletred"),
        css_keyword("papayawhip"),
        css_keyword("peachpuff"),
        css_keyword("peru"),
        css_keyword("pink"),
        css_keyword("plum"),
        css_keyword("powderblue"),
        css_keyword("purple"),
        css_keyword("rebeccapurple"),
        css_keyword("red"),
        css_keyword("rosybrown"),
        css_keyword("royalblue"),
        css_keyword("saddlebrown"),
        css_keyword("salmon"),
        css_keyword("sandybrown"),
        css_keyword("seagreen"),
        css_keyword("seashell"),
        css_keyword("sienna"),
        css_keyword("silver"),
        css_keyword("skyblue"),
        css_keyword("slateblue"),
        css_keyword("slategray"),
        css_keyword("slategrey"),
        css_keyword("snow"),
        css_keyword("springgreen"),
        css_keyword("steelblue"),
        css_keyword("tan"),
        css_keyword("teal"),
        css_keyword("thistle"),
        css_keyword("tomato"),
        css_keyword("turquoise"),
        css_keyword("violet"),
        css_keyword("wheat"),
        css_keyword("white"),
        css_keyword("whitesmoke"),
        css_keyword("yellow"),
        css_keyword("yellowgreen"),
      ),

    // https://www.w3.org/TR/css-color-4/#transparent-color
    css_keyword_transparent: (_) => css_keyword("transparent"),

    // https://www.w3.org/TR/css-color-4/#missing
    css_keyword_none: (_) => css_keyword("none"),

    u32_argb: (_) =>
      /0[xX][0-9a-fA-F]_?[0-9a-fA-F]_?[0-9a-fA-F]_?[0-9a-fA-F]_?[0-9a-fA-F]_?[0-9a-fA-F]_?[0-9a-fA-F]_?[0-9a-fA-F]/,

    tailwindcss_color: ($) =>
      choice(
        // https://tailwindcss.com/docs/colors#using-color-utilities
        $.tailwindcss_color_classname_without_alpha,

        // https://tailwindcss.com/docs/colors#adjusting-opacity
        $.tailwindcss_color_classname_with_alpha_percentage,

        // https://tailwindcss.com/docs/colors#adjusting-opacity
        $.tailwindcss_color_classname_with_alpha_arbitrary_value,

        // https://tailwindcss.com/docs/colors#referencing-in-css
        $.tailwindcss_color_css_variable_without_alpha,

        // https://tailwindcss.com/docs/colors#referencing-in-css
        $.tailwindcss_color_css_variable_with_alpha,
      ),

    tailwindcss_color_css_variable_without_alpha: (_) =>
      token(seq("--color-", tailwindcss_color_name)),

    tailwindcss_color_css_variable_with_alpha: ($) =>
      seq(
        "--alpha(",
        "var(",
        field("css_variable", $.tailwindcss_color_css_variable_without_alpha),
        ")",
        "/",
        field("alpha", choice($.css_number, $.css_percentage)),
        ")",
      ),

    tailwindcss_color_classname_without_alpha: (_) =>
      token(seq(tailwindcss_color_utility, "-", tailwindcss_color_name)),

    tailwindcss_color_classname_with_alpha_percentage: (_) =>
      token(
        seq(
          tailwindcss_color_utility,
          "-",
          tailwindcss_color_name,
          "/",
          css_number,
        ),
      ),

    tailwindcss_color_classname_with_alpha_arbitrary_value: (_) =>
      token(
        seq(
          tailwindcss_color_utility,
          "-",
          tailwindcss_color_name,
          "/",
          "[",
          choice(css_number, css_percentage),
          "]",
        ),
      ),

    _symbol: (_) => symbol,
    _non_symbol: (_) => non_symbol,
    non_whitespace: (_) => non_whitespace,
  },
});
