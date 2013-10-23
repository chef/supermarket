Super Market
============

Super Market is Opscode's Individual Contributor License Agreement (ICLA) service. It performs a variety of functions including:

- Exposing an API for other services to consume
- Storing user-information and CLA status
- More...

Trello Project: https://trello.com/c/aBFr3DaK

Requirements
------------
- Ruby 2.0.0
- PostgreSQL 9.3+

Front-End Assets
----------------

[Half Pipe](https://github.com/d-i/half-pipe) is used rather than the Asset Pipeline for managing assets. This uses [Grunt](http://gruntjs.com/) to do all of the work related to the JavaScript and Sass. The main differences are:

* [RequireJS](http://requirejs.org/) is used instead of Sprockets.
* JavaScripts and stylesheets are stored in app/scripts and app/styles instead of app/assets/javascripts and app/assets/stylesheets
* `grunt server` is used instead of `rails server`. This watches the assets and config files and automatically recompiles and reloads when changes happen.
* `grunt build:public` is used instead of `rake assets:precompile`
* Instead of installing JavaScripts through gems or putting them in vendor/assets/javascripts, they can be installed with [Bower](http://bower.io/) and their module paths for RequireJS can be configured in config/build.js.

Other Stuff We Need to Document
-------------------------------

- System dependencies
- Configuration
- Database creation
- Database initialization
- How to run the test suite
- Services (job queues, cache servers, search engines, etc.)
- Deployment instructions
