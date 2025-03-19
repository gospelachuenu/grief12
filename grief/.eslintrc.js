module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended"
  ],
  rules: {
    "no-unused-vars": "off",
    "no-restricted-globals": "off",
    "prefer-arrow-callback": "off",
    "quotes": "off"
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
};
