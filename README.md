Super Market
============

Super Market is Opscode's Individual Contributor License Agreement (ICLA) service. It performs a variety of functions including:

- Exposing an API for other services to consume
- Storing user-information and CLA status
- More...

Trello Project: https://trello.com/c/aBFr3DaK

Database Setup
--------------

To create the database and populate it, make sure your config/database.yml has
the correct values. Then run:

```sh
rake db:create
rake db:migrate
rake db:seed
```

OmniAuth
--------

Super Market uses [OmniAuth](https://github.com/intridea/omniauth) for authentication. The OmniAuth configuration is data-driven, so you can configure OmniAuth to use whatever authentication method your organization desires. You can read more about OmniAuth on the [OmniAuth GitHub page](https://github.com/intridea/omniauth). In short, you need to create and register Super Market as an application and setup the keys in the `config/application.yml` file.

To register GitHub as an OmniAuth login method:

1. [Register your application](https://github.com/settings/applications/new)
2. Make sure the Authorization callback URL has the app's URL with the /auth/github/callback path
3. Add the following to your `config/application.yml`:
  ```yaml
  omni_auth:
    github:
      key: MY_KEY
      secret: MY_SECRET
  ```

where `MY_KEY` and `MY_SECRET` are the values given when you created the application.

You can register Twitter as a provider by creating an application on the [Twitter Developers site](https://dev.twitter.com/apps).

### Adding Additional Providers

You can add support for additional OAUTH providers by creating an extractor object in `app/extractors`.

Since each OmniAuth provider returns a different set of information, you often end up with nested case statements to account for all the different providers. Super Market accounts for this behavior using Extractor objects. Each OmniAuth provider must have an associated Extractor object that extracts the correct information from the OmniAuth response hash into a object with a unified interface.

Requirements
------------

- Ruby 2.0.0
- PostgreSQL 9.3+

Tests
-----

### Acceptance tests

Acceptance tests are run with [Capybara](https://github.com/jnicklas/capybara). Run `rake spec:features` to run the specs in spec/features. The default `rake spec` also runs these.

When writing a feature, use `require 'spec_feature_helper'` instead of `spec_helper` to require the extra configuration and libraries needed to run the feature specs.

The specs run using [PhantomJS](http://phantomjs.org/), which must be installed.

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
