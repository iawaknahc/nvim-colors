#!/usr/bin/env -S awk -f

BEGIN {
	escape[0] = "\x1b";
	escape[1] = "\\033";
	escape[2] = "\\x1b";
	escape[3] = "\\x1B";
	escape[4] = "\\u001b";
	escape[5] = "\\u001B";
	escape[6] = "\\U0000001b";
	escape[7] = "\\U0000001B";
	escape[8] = "\\e";
	escape[9] = "\\u{1b}";
	escape[10] = "\\u{1B}";
	escape[11] = "\\u{01b}";
	escape[12] = "\\u{01B}";
	n[0] = "38";
	n[1] = "48";
	for (escape_idx in escape) {
		for (n_idx in n) {
			for (r = 0; r <= 255; r += 51) {
				for (g = 0; g <= 255; g += 51) {
					for (b = 0; b <= 255; b += 51) {
						printf("%s[%s;2;%d;%d;%dm\n", escape[escape_idx], n[n_idx], r, g, b);
					}
				}
			}
		}
	}
}
