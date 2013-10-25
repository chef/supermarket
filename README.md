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

Tests
-----

### JavaScript Tests

The JavaScript specs are run with [Karma](http://karma-runner.github.io) and use the [Mocha](http://visionmedia.github.io/mocha/) test framework and the [Chai Assertion Library](http://chaijs.com/)

The specs live in spec/javascripts. Run `rake spec:js` to run the specs, and `rake spec:js:watch` to run them continuously and watch for changes.

[Node.js](http://nodejs.org/) is required to run the JavaScript tests.

Other Stuff We Need to Document
-------------------------------

- System dependencies
- Configuration
- Database creation
- Database initialization
- How to run the test suite
- Services (job queues, cache servers, search engines, etc.)
- Deployment instructions
