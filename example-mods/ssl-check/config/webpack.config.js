const path = require("path");
const OnlyIfChangedPlugin = require("only-if-changed-webpack-plugin");

const opts = {
  rootDir: process.cwd(),
  devBuild: process.env.NODE_ENV !== "production"
};

module.exports = {
  target: "node",
  // plugins: [new BundleAnalyzerPlugin()],
  plugins: [
    new OnlyIfChangedPlugin({
      cacheDirectory: path.join(opts.rootDir, "dist/cache"),
      cacheIdentifier: opts // all variable opts/environment should be used in cache key
    })
  ],
  entry: "./index.js",
  output: {
    libraryTarget: "commonjs",

    // Don't use __dirname because that means the location of this file while we want the output
    // to be under the lambda function
    path: path.resolve(opts.rootDir, "dist"),
    filename: "index.js"
  },
  mode: "development",
  externals: {
    // Possible drivers for knex - we'll ignore them
    sqlite3: "sqlite3",
    mariasql: "mariasql",
    mssql: "mssql",
    mysql: "mysql",
    mysql2: "mysql2",
    oracle: "oracle",
    "strong-oracle": "strong-oracle",
    oracledb: "oracledb",
    "pg-query-stream": "pg-query-stream",
    "pg-native": "pg-native"
  }
};
