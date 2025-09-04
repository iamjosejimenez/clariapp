module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "!./app/assets/build/**",
    "!./node_modules/**",
    "!./tmp/**"
  ],
  theme: {},
  plugins: []
}
