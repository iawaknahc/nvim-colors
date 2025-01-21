import commonjs from "@rollup/plugin-commonjs";
import { nodeResolve } from "@rollup/plugin-node-resolve";

export default {
  input: "./src/index.mjs",
  output: {
    file: "./rplugin/node/nvim-colors/index.js",
    format: "cjs",
  },
  plugins: [commonjs(), nodeResolve()],
};
