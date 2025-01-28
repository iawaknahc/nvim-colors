#!/bin/sh

echo "transparent"

cat <<EOF
aliceblue
antiquewhite
aqua
aquamarine
azure
beige
bisque
black
blanchedalmond
blue
blueviolet
brown
burlywood
cadetblue
chartreuse
chocolate
coral
cornflowerblue
cornsilk
crimson
cyan
darkblue
darkcyan
darkgoldenrod
darkgray
darkgreen
darkgrey
darkkhaki
darkmagenta
darkolivegreen
darkorange
darkorchid
darkred
darksalmon
darkseagreen
darkslateblue
darkslategray
darkslategrey
darkturquoise
darkviolet
deeppink
deepskyblue
dimgray
dimgrey
dodgerblue
firebrick
floralwhite
forestgreen
fuchsia
gainsboro
ghostwhite
gold
goldenrod
gray
green
greenyellow
grey
honeydew
hotpink
indianred
indigo
ivory
khaki
lavender
lavenderblush
lawngreen
lemonchiffon
lightblue
lightcoral
lightcyan
lightgoldenrodyellow
lightgray
lightgreen
lightgrey
lightpink
lightsalmon
lightseagreen
lightskyblue
lightslategray
lightslategrey
lightsteelblue
lightyellow
lime
limegreen
linen
magenta
maroon
mediumaquamarine
mediumblue
mediumorchid
mediumpurple
mediumseagreen
mediumslateblue
mediumspringgreen
mediumturquoise
mediumvioletred
midnightblue
mintcream
mistyrose
moccasin
navajowhite
navy
oldlace
olive
olivedrab
orange
orangered
orchid
palegoldenrod
palegreen
paleturquoise
palevioletred
papayawhip
peachpuff
peru
pink
plum
powderblue
purple
rebeccapurple
red
rosybrown
royalblue
saddlebrown
salmon
sandybrown
seagreen
seashell
sienna
silver
skyblue
slateblue
slategray
slategrey
snow
springgreen
steelblue
tan
teal
thistle
tomato
turquoise
violet
wheat
white
whitesmoke
yellow
yellowgreen
EOF

range() {
	awk -v START_="$1" -v END_="$2" -v STEP_="$3" 'BEGIN { for (i = START_; i <= END_; i += STEP_) print i }'
}

range 0 100 10 | while read -r r; do
	range 0 100 10 | while read -r g; do
		range 0 100 10 | while read -r b; do
			echo "rgb($r% $g% $b%)"
		done
	done
done

range 0 360 36 | while read -r h; do
	range 0 100 10 | while read -r s; do
		range 0 100 10 | while read -r l; do
			echo "hsl(${h}deg $s% $l%)"
		done
	done
done

range 0 360 36 | while read -r h; do
	range 0 100 10 | while read -r w; do
		range 0 100 10 | while read -r b; do
			echo "hwb(${h}deg $w% $b%)"
		done
	done
done

range 0 100 10 | while read -r l; do
	range 0 100 10 | while read -r a; do
		range 0 100 10 | while read -r b; do
			echo "oklab($l% $a% $b%)"
		done
	done
done

range 0 100 10 | while read -r l; do
	range 0 100 10 | while read -r c; do
		range 0 360 36 | while read -r h; do
			echo "oklch($l% $c% ${h}deg)"
		done
	done
done

for space in srgb srgb-linear display-p3 a98-rgb prophoto-rgb rec2020; do
	range 0 100 10 | while read -r r; do
		range 0 100 10 | while read -r g; do
			range 0 100 10 | while read -r b; do
				echo "color($space $r% $g% $b%)"
			done
		done
	done
done

for space in xyz xyz-d50 xyz-d65; do
	range 0 100 10 | while read -r x; do
		range 0 100 10 | while read -r y; do
			range 0 100 10 | while read -r z; do
				echo "color($space $x% $y% $z%)"
			done
		done
	done
done
