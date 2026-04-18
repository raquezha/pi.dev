module.exports = [
  // global ignore patterns
  {
    ignores: [
      "node_modules/**",
      "dist/**",
      "*.min.js",
      ".env",
      ".vscode/**",
      ".pi/agent/**"
    ]
  },
  // JS/TS rules
  {
    files: ["**/*.ts", "**/*.js"],
    languageOptions: {
      parser: require("@typescript-eslint/parser"),
      parserOptions: {
        project: "./tsconfig.json",
        tsconfigRootDir: __dirname,
        sourceType: "module"
      }
    },
    plugins: {
      "@typescript-eslint": require("@typescript-eslint/eslint-plugin"),
      "prettier": require("eslint-plugin-prettier")
    },
    rules: {
      "no-console": "off",
      "@typescript-eslint/explicit-module-boundary-types": "off",
      "prettier/prettier": "error"
    }
  }
];
