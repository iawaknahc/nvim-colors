const digit0 = ["0", "f"];
const digit = ["0", "f", "_0", "_f"];

for (const prefix of ["0x", "0X"]) {
  for (const _0 of digit0) {
    for (const _1 of digit) {
      for (const _2 of digit) {
        for (const _3 of digit) {
          for (const _4 of digit) {
            for (const _5 of digit) {
              for (const _6 of digit) {
                for (const _7 of digit) {
                  console.log(
                    `${prefix}${_0}${_1}${_2}${_3}${_4}${_5}${_6}${_7}`,
                  );
                }
              }
            }
          }
        }
      }
    }
  }
}
