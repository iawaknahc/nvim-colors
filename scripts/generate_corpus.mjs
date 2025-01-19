import Color from "colorjs.io";

// transparent
console.log("transparent");

const named_colors = [
  "aliceblue",
  "antiquewhite",
  "aqua",
  "aquamarine",
  "azure",
  "beige",
  "bisque",
  "black",
  "blanchedalmond",
  "blue",
  "blueviolet",
  "brown",
  "burlywood",
  "cadetblue",
  "chartreuse",
  "chocolate",
  "coral",
  "cornflowerblue",
  "cornsilk",
  "crimson",
  "cyan",
  "darkblue",
  "darkcyan",
  "darkgoldenrod",
  "darkgray",
  "darkgreen",
  "darkgrey",
  "darkkhaki",
  "darkmagenta",
  "darkolivegreen",
  "darkorange",
  "darkorchid",
  "darkred",
  "darksalmon",
  "darkseagreen",
  "darkslateblue",
  "darkslategray",
  "darkslategrey",
  "darkturquoise",
  "darkviolet",
  "deeppink",
  "deepskyblue",
  "dimgray",
  "dimgrey",
  "dodgerblue",
  "firebrick",
  "floralwhite",
  "forestgreen",
  "fuchsia",
  "gainsboro",
  "ghostwhite",
  "gold",
  "goldenrod",
  "gray",
  "green",
  "greenyellow",
  "grey",
  "honeydew",
  "hotpink",
  "indianred",
  "indigo",
  "ivory",
  "khaki",
  "lavender",
  "lavenderblush",
  "lawngreen",
  "lemonchiffon",
  "lightblue",
  "lightcoral",
  "lightcyan",
  "lightgoldenrodyellow",
  "lightgray",
  "lightgreen",
  "lightgrey",
  "lightpink",
  "lightsalmon",
  "lightseagreen",
  "lightskyblue",
  "lightslategray",
  "lightslategrey",
  "lightsteelblue",
  "lightyellow",
  "lime",
  "limegreen",
  "linen",
  "magenta",
  "maroon",
  "mediumaquamarine",
  "mediumblue",
  "mediumorchid",
  "mediumpurple",
  "mediumseagreen",
  "mediumslateblue",
  "mediumspringgreen",
  "mediumturquoise",
  "mediumvioletred",
  "midnightblue",
  "mintcream",
  "mistyrose",
  "moccasin",
  "navajowhite",
  "navy",
  "oldlace",
  "olive",
  "olivedrab",
  "orange",
  "orangered",
  "orchid",
  "palegoldenrod",
  "palegreen",
  "paleturquoise",
  "palevioletred",
  "papayawhip",
  "peachpuff",
  "peru",
  "pink",
  "plum",
  "powderblue",
  "purple",
  "rebeccapurple",
  "red",
  "rosybrown",
  "royalblue",
  "saddlebrown",
  "salmon",
  "sandybrown",
  "seagreen",
  "seashell",
  "sienna",
  "silver",
  "skyblue",
  "slateblue",
  "slategray",
  "slategrey",
  "snow",
  "springgreen",
  "steelblue",
  "tan",
  "teal",
  "thistle",
  "tomato",
  "turquoise",
  "violet",
  "wheat",
  "white",
  "whitesmoke",
  "yellow",
  "yellowgreen",
];

for (const named of named_colors) {
  console.log(named);
}

// rgb
for (let r = 0; r <= 100; r += 10) {
  for (let g = 0; g <= 100; g += 10) {
    for (let b = 0; b <= 100; b += 10) {
      const color = new Color(`rgb(${r}% ${g}% ${b}%)`);
      console.log(color.toString());
    }
  }
}

// hsl
for (let h = 0; h <= 360; h += 36) {
  for (let s = 0; s <= 100; s += 10) {
    for (let l = 0; l <= 100; l += 10) {
      const color = new Color(`hsl(${h}deg ${s}% ${l}%)`);
      console.log(color.toString());
    }
  }
}

// hwb
for (let h = 0; h <= 360; h += 36) {
  for (let w = 0; w <= 100; w += 10) {
    for (let b = 0; b <= 100; b += 10) {
      const color = new Color(`hwb(${h}deg ${w}% ${b}%)`);
      console.log(color.toString());
    }
  }
}

// oklab
for (let l = 0; l <= 100; l += 10) {
  for (let a = 0; a <= 100; a += 10) {
    for (let b = 0; b <= 100; b += 10) {
      const color = new Color(`oklab(${l}% ${a}% ${b}%)`);
      console.log(color.toString());
    }
  }
}

// oklch
for (let l = 0; l <= 100; l += 10) {
  for (let c = 0; c <= 100; c += 10) {
    for (let h = 0; h <= 360; h += 36) {
      const color = new Color(`oklch(${l}% ${c}% ${h}deg)`);
      console.log(color.toString());
    }
  }
}

// color rgb
for (const space of [
  "srgb",
  "srgb-linear",
  "display-p3",
  "a98-rgb",
  "prophoto-rgb",
  "rec2020",
]) {
  for (let r = 0; r <= 100; r += 10) {
    for (let g = 0; g <= 100; g += 10) {
      for (let b = 0; b <= 100; b += 10) {
        const color = new Color(`color(${space} ${r}% ${g}% ${b}%)`);
        console.log(color.toString());
      }
    }
  }
}

// color xyz
for (const space of ["xyz", "xyz-d50", "xyz-d65"]) {
  for (let x = 0; x <= 100; x += 10) {
    for (let y = 0; y <= 100; y += 10) {
      for (let z = 0; z <= 100; z += 10) {
        const color = new Color(`color(${space} ${x}% ${y}% ${z}%)`);
        console.log(color.toString());
      }
    }
  }
}
