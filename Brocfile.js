// Import some Broccoli plugins
var filterCoffeeScript = require('broccoli-coffee');
var mergeTrees         = require('broccoli-merge-trees');
var concatenate        = require('broccoli-concat');
var pickFiles          = require('broccoli-static-compiler');
var uglifyJs           = require('broccoli-uglify-js');

// Specify the coffeescript directory
var coffeeDir = 'app/';

// Tell Broccoli how we want the assets to be compiled
var scripts = filterCoffeeScript(coffeeDir);
scripts = concatenate(scripts, {
  inputFiles: ['**/*.js'],
  outputFile: '/app.js',
  header: '/** created by jakerunzer **/'
});
scripts = uglifyJs(scripts, {
  compress: true
});

// Merge the compiled styles and scripts into one output directory.
module.exports = mergeTrees([scripts]);
