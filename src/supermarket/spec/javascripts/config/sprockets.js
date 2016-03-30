// Get all of the app's sprocket's dependencies as an array for testing.
var SprocketsChain = require('sprockets-chain'),
    sc = new SprocketsChain();

// Append paths to the list of load paths
sc.appendPath('app/assets/javascripts');
sc.appendPath('vendor/assets/javascripts');

// Get ordered array of individual absolute file paths that compose the
// `application.js` bundle
module.exports = sc.depChain('application.js');
