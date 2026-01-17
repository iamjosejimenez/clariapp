// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')

const customConfig = {
  watchOptions: {
    ignored: /node_modules|tmp|app\/assets\/|public\/packs/
  },
}

module.exports = generateWebpackConfig(customConfig);
