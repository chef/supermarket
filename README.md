# Supermarket

[![Code Climate](https://codeclimate.com/github/chef/supermarket.png)](https://codeclimate.com/github/chef/supermarket) [![Build Status](https://travis-ci.org/chef/supermarket.png?branch=master)](https://travis-ci.org/chef/supermarket) [![Dependency Status](https://gemnasium.com/chef/supermarket.png)](https://gemnasium.com/chef/supermarket) [![Coverage Status](https://coveralls.io/repos/chef/supermarket/badge.png?branch=master)](https://coveralls.io/r/chef/supermarket?branch=master) [![Inline docs](http://inch-ci.org/github/chef/supermarket.png)](http://inch-ci.org/github/chef/supermarket) [![Gitter chat](https://badges.gitter.im/chef/supermarket.png)](https://gitter.im/chef/supermarket) [![Stories in Ready](https://badge.waffle.io/chef/supermarket.png?label=ready&title=Ready)](https://waffle.io/chef/supermarket)

Supermarket is Chef's community repository for cookbooks, currently hosted
at [supermarket.chef.io](supermarket.chef.io). Supermarket can also be run
internally, behind-the-firewall.

The code is designed to be easy for others to contribute to. To that end,
the goal of this README is to introduce you to the project and get you up and
running. More information about Supermarket can be found in [the
wiki](https://github.com/chef/supermarket/wiki).
[View the roadmap](https://github.com/chef/supermarket/wiki/Roadmap), and
[follow along with the project development in
waffle.io](https://waffle.io/chef/supermarket). Supermarket has
[an open project chat on Gitter](https://gitter.im/chef/supermarket)
and [a mailing list](https://groups.google.com/forum/#!forum/chef-supermarket).

If you want to contribute to Supermarket, read the [contributor's
workflow](https://github.com/chef/supermarket/blob/master/CONTRIBUTING.md)
for license information and helpful tips to get you started. There are project artifacts such as planning docs, wireframes, recorded
demos, and team retrospectives in a [public Google Drive
folder](https://drive.google.com/a/gofullstack.com/#folders/0B6WV7Qy0ZCUfbFFPNG9CejExUW8)
and on [InVision](https://projects.invisionapp.com/share/VMOMTJ36#/screens).

If you have questions, feature ideas, or other suggestions, please [open a
GitHub Issue](https://github.com/chef/supermarket/issues/new).

This repository has the code for the Supermarket application, related
repositories are:

* [chef-cookbooks/supermarket](https://github.com/chef-cookbooks/supermarket): The cookbook used to deploy the application
* [chef/omnibus-supermarket](https://github.com/chef/omnibus-supermarket): Code used to build RPM and DEB packages

## Requirements

- Ruby 2.1.3
- PostgreSQL 9.2
- Redis 2.4+

## Development

### Configuring

Configure the [dotenv](https://github.com/bkeepers/dotenv) keys and secrets to .
See `.env.example` for required keys and secrets to get up and running.
[`docs/CONFIGURING.md`](https://github.com/chef/supermarket/blob/master/docs/CONFIGURING.md)
goes into detail about the not-so-straightforward configuration that needs
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
(https://github.com/chef/supermarket/wiki/Changing-the-Vagrant-VM-Defaults)

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
These instructions are tested and verified on Mac OS X Yosemite

1. Install a Ruby manager - if you don't already have one, you will need a Ruby manager to install Ruby 2.1.3 such as:
   * [RVM](https://rvm.io)
   * [Rbenv](https://github.com/sstephenson/rbenv)
   * [chruby] (https://github.com/postmodern/chruby)
   * or any other Ruby version manager that may come along

1. Use your ruby manager to install Ruby 2.1.3.  For instructions on this, please see the manager's documentation.

1. Install Postgres - There are two ways to install Postgres on OS X
  * Install the [Postgres App](http://postgresapp.com/).  This is probably the simplest way to get Postgres running on your mac, it "just works."  You can then start a Postgres server through the GUI of the app
  * Through [Homebrew](http://brew.sh/).  Supermarket requires Postgresql version 9.2.  Homebrew will install a later version by default. To install the earlier version using homebrew see this [stack overflow](http://stackoverflow.com/questions/3987683/homebrew-install-specific-version-of-formula).  When installed through homebrew, Postgres often requires additional configuration, see this [blog post](https://www.codefellows.org/blog/three-battle-tested-ways-to-install-postgresql) for instructions.  You can then start the Postgresql server with

  ```
  $ pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
  ```

1. Install Redis.  You can install this with Homebrew.  Follow the instructions in the install output to start the redis server.

  ```
  $ brew install redis
  ```

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
(https://github.com/chef/supermarket/blob/master/spec/features/remove_members_from_ccla_spec.rb#L17)
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
(https://github.com/chef/supermarket/wiki/Background-Jobs).

## Deployment

[Read about Deployment instructions in the wiki.]
(https://github.com/chef/supermarket/wiki/Deployment)

## Feature Flags

Supermarket uses a `.env` file to configure itself. Inside this file are
key/value pairs. These key/value pairs will be exported as environment
variables when the app runs, and Supermarket will look for these keys as
environment variables when it needs to read a value that's configurable.

One of these keys is called `FEATURES` and it controls a number of features
that can be turned on and off. Here are the available features that can be
toggled:

* cla
* join_ccla
* tools
* fieri
* announcement
* github
* no_crawl

# License

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Copyright:**       | Copyright (c) 2014-2015 Chef Software, Inc.
| **License:**         | Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
