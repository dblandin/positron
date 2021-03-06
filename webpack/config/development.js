// @ts-check

const merge = require("webpack-merge")
const webpack = require("webpack")
const common = require("../index.js")
const { getEntrypoints } = require("../helpers")

module.exports = merge(common, {
  mode: "development",
  devtool: "cheap-module-eval-source-map",
  entry: {
    webpack: [
      "webpack-hot-middleware/client?reload=true",
      "./src/client/apps/webpack/client.js",
    ],
    ...getEntrypoints(),
  },
  plugins: [new webpack.HotModuleReplacementPlugin()],
})
