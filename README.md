[![Stories in Ready](https://badge.waffle.io/opscode/supermarket.png?label=ready&title=Ready)](https://waffle.io/opscode/supermarket)
# Supermarket

[![Code Climate](https://codeclimate.com/github/opscode/supermarket.png)](https://codeclimate.com/github/opscode/supermarket) [![Build Status](https://travis-ci.org/opscode/supermarket.png?branch=master)](https://travis-ci.org/opscode/supermarket) [![Dependency Status](https://gemnasium.com/opscode/supermarket.png)](https://gemnasium.com/opscode/supermarket) [![Coverage Status](https://coveralls.io/repos/opscode/supermarket/badge.png?branch=master)](https://coveralls.io/r/opscode/supermarket?branch=master) [![Inline docs](http://inch-ci.org/github/opscode/supermarket.png)](http://inch-ci.org/github/opscode/supermarket) [![Gitter chat](https://badges.gitter.im/opscode/supermarket.png)](https://gitter.im/opscode/supermarket)

Supermarket is Chef's new community project with the goals of being the
community repository for cookbooks, an easy to contribute to project, and
the behind-the-firewall solution to serving cookbooks.

The goal of this README is to introduce you to the project and get you up and
running. More information about Supermarket can be found in [the
wiki](https://github.com/opscode/supermarket/wiki). Supermarket is currently
pre-release and under active development. [View the
roadmap](https://github.com/opscode/supermarket/wiki/Roadmap), and
[follow along with the project development in
Trello](https://trello.com/b/IGLbkBWL/supermarket). Supermarket has
[an open project chat on Gitter](https://gitter.im/opscode/supermarket)
and [a mailing list](https://groups.google.com/forum/#!forum/chef-supermarket).

If you want to contribute to Supermarket, read the [contributor's
workflow](https://github.com/opscode/supermarket/blob/master/CONTRIBUTING.md)
for license information and helpful tips to get you started. There are project artifacts such as planning docs, wireframes, recorded
demos, and team retrospectives in a [public Google Drive
folder](https://drive.google.com/a/gofullstack.com/#folders/0B6WV7Qy0ZCUfbFFPNG9CejExUW8)
and on [InVision](https://projects.invisionapp.com/share/VMOMTJ36#/screens).

If you have questions, feature ideas, or other suggestions, please [open a
GitHub Issue](https://github.com/opscode/supermarket/issues/new).

## Requirements

- Ruby 2.0.0
- PostgreSQL 9.3+
- Redis 2.4+

## Development

### Configuring

Configure the [dotenv](https://github.com/bkeepers/dotenv) keys and secrets to .
See `.env.example` for required keys and secrets to get up and running.
[`docs/CONFIGURING.md`](https://github.com/opscode/supermarket/blob/master/docs/CONFIGURING.md)
goes into detail about the not so straight forward configuration that needs
to happen to get Supermarket working locally.

### Using Vagrant (Beginner)

Supermarket includes a collection of Chef cookbooks and a preconfigured
`Vagrantfile` to make it easy to get up an running without modifying your local system.

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and
[Vagrant](http://www.vagrantup.com/downloads.html)

1. Install the `vagrant-omnibus` plugin:

  ```
  $ vagrant plugin install vagrant-omnibus
  ```

1. Install the `vagrant-berkshelf` plugin:

  ```
  $ vagrant plugin install vagrant-berkshelf --plugin-version '>= 2.0.1'
  ```

1. Run the server:

  ```
  $ ./bin/supermarket server
  ```

The next time you want to start the application, you only need to run:

```
$ ./bin/supermarket server
```

#### About Vagrant

Vagrant uses VirtualBox to run a VM that has access to the application project
files. It syncs your local project files with the VM. Running the
`./bin/supermarket server` command spins up a VM. When you are done running the
application, do not forget to run `vagrant suspend` or `vagrant halt` to give
the VM a break.

You can [read more about Vagrant teardown in the Vagrant
docs](http://docs.vagrantup.com/v2/getting-started/teardown.html).

[Read more about changing the Vagrant VM defaults in the wiki.]
(https://github.com/opscode/supermarket/wiki/Changing-the-Vagrant-VM-Defaults)

#### Guest Additions

If you get an error about Guest Additions, install the `vagrant-vbguest` vagrant
plugin:

```
$ vagrant plugin install vagrant-vbguest
```

#### Switching from Vagrant to Local Environment Development

If you want to switch from Vagrant to your developing locally, you have two
options:

When Vagrant runs `bundle install` it installs the gems into `vendor/ruby/gems`.
This is because of the Bundler config in `.bundle/config`.

1. If you want to continue to install gems in `vendor/ruby/gems`, delete that
   directory and run `bundle install`. This will rebuild the gems with native
   dependencies on your local machine instead of the Vagrant VM.
1. If you want to install your gems system wide, delete the `.bundle`
   directory.


### Local Environment (Advanced)

1. Install Ruby 2.0 (latest patch) using your favorite Ruby manager
1. Install Postgres (from [homebrew](http://brew.sh/) or the [app](http://postgresapp.com/))
   NOTE: This application requires Postgresql version 9.2.  Homebrew will install a later version by default.  To install the earlier version using homebrew see this [stack overflow](http:
//stackoverflow.com/a/4158763)
1. Install Redis (required to run background jobs)
1. Make sure both Postgres and the Redis server are running
1. Install bundler

  ```
  $ gem install bundler
  ```

1. Install required gems:

  ```
  $ bundle
  ```

1. Create the database, migrate the database and seed the database:

  ```
  $ bundle exec rake db:setup
  ```

1. Add required Postgres extensions.

  ```
  $ psql supermarket_development -c 'create extension plpgsql'
  $ psql supermarket_development -c 'create extension pg_trgm'
  ```

1. Start the server:

  ```
  $ foreman start
  ```

## Tests

Run the entire test suite (rspec, rubocop and mocha) with:

``` sh
$ bundle exec rake spec:all
```

### Acceptance Tests

Acceptance tests are run with [Capybara](https://github.com/jnicklas/capybara).
Run `rake spec:features` to run the specs in spec/features. The default `rake
spec` also runs these.

When writing a feature, use `require 'spec_feature_helper'` instead of
`spec_helper` to require the extra configuration and libraries needed to run the
feature specs.

When writing feature specs, the Rack::Test driver is used by default. If the
Poltergeist driver is required to be used (for example, an acceptance test
that uses AJAX), add the `use_poltergeist: true` metadata to the spec. See
[the remove_members_from_ccla_spec.rb spec]
(https://github.com/opscode/supermarket/blob/master/spec/features/remove_members_from_ccla_spec.rb#L17)
for an example.

Some specs run using [PhantomJS](http://phantomjs.org/), which must be
installed for the test suite to pass.

### JavaScript Tests

The JavaScript specs are run with [Karma](http://karma-runner.github.io) and use
the [Mocha](http://visionmedia.github.io/mocha/) test framework and the [Chai
Assertion Library](http://chaijs.com/)

The specs live in spec/javascripts. Run `rake spec:javascripts` to run the
specs, and `rake spec:javascripts:watch` to run them continuously and watch for
changes.

[Node.js](http://nodejs.org/) is required to run the JavaScript tests.

## Background Jobs

[Read about Supermarket's background jobs in the wiki]
(https://github.com/opscode/supermarket/wiki/Background-Jobs).

## Deployment

[Read about Deployment instructions in the wiki.]
(https://github.com/opscode/supermarket/wiki/Deployment)
