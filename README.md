# Supermarket

[![unit](https://github.com/chef/supermarket/actions/workflows/unit.yml/badge.svg)](https://github.com/chef/supermarket/actions/workflows/unit.yml)
[![lint](https://github.com/chef/supermarket/actions/workflows/lint.yml/badge.svg)](https://github.com/chef/supermarket/actions/workflows/lint.yml)
[![ctl-cookbook-testing](https://github.com/chef/supermarket/actions/workflows/ctl-cookbook-testing.yml/badge.svg)](https://github.com/chef/supermarket/actions/workflows/ctl-cookbook-testing.yml)
[![Inline docs](http://inch-ci.org/github/chef/supermarket.svg)](http://inch-ci.org/github/chef/supermarket)

Supermarket is Chef's community repository for cookbooks, currently hosted at [supermarket.chef.io](supermarket.chef.io). Supermarket can also run internally, behind-the-firewall.

**Umbrella Project**: [Supermarket](https://github.com/chef/chef-oss-practices/blob/master/projects/supermarket.md)

* **[Project State](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md):** Maintained
* **Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md):** 14 days
* **Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md):** 14 days

The code is designed to be easy for others to contribute to. To that end, the goal of this README is to introduce you to the project and get you up and running. More information about Supermarket can be found in [the wiki](https://github.com/chef/supermarket/wiki). You can [follow along with the project development in ZenHub](https://app.zenhub.com/workspaces/supermarket-60cbda5a95f583001207255f).

If you want to contribute to Supermarket, read the [contributor's workflow](https://github.com/chef/supermarket/blob/main/CONTRIBUTING.md) for license information and helpful tips to get you started. There are project artifacts such as planning docs, wireframes, recorded demos, and team retrospectives in a [public Google Drive folder](https://drive.google.com/a/gofullstack.com/#folders/0B6WV7Qy0ZCUfbFFPNG9CejExUW8).

If you have questions, feature ideas, or other suggestions, please [open a GitHub Issue](https://github.com/chef/supermarket/issues/new).

This repository has the code for the Supermarket application and the omnibus definition used to build the deb/rpm packages. Other Supermarket related repositories are:

* [chef-cookbooks/supermarket-omnibus-cookbook](https://github.com/chef-cookbooks/supermarket-omnibus-cookbook): This cookbook is used to deploy Supermarket through the Supermarket omnibus package. For details on using this cookbook to install Supermarket omnibus, check out [this webinar by the Supermarket Engineering team](https://www.chef.io/webinars/?commid=164925).

## Requirements

* Ruby 2.7.4
* PostgreSQL 9.3
* Redis 6.2.5

## Development

### Configuring

Configure the [dotenv](https://github.com/bkeepers/dotenv) keys and secrets to. See `.env.example` for required keys and secrets to get up and running. [`docs/CONFIGURING.md`](https://github.com/chef/supermarket/blob/main/src/supermarket/docs/CONFIGURING.md) goes into detail about the not-so-straightforward configuration that needs to happen to get Supermarket working locally.

### Local Environment

These instructions are tested and verified on macOS Catalina (10.15)

#### Dependency Services

##### As Docker Containers

1. Install `docker`

    ```shell
    brew cask install docker
    ```

    **NOTE:** You will still need a version of PostgreSQL installed on the local filesystem for development libraries to be available for building the `pg` gem. See the instructions for locally running PostgreSQL below, but omit the steps where the service is started.

1. Start the docker containers

    ```shell
    cd src/supermarket
    docker-compose up
    ```

##### As Locally Running Processes

1. Install Postgres - There are a few ways to get PostgreSQL running on macOS

    * Install the [Postgres App](http://postgresapp.com/):

      This is probably the simplest way to get Postgres running on your mac, it "just works."  You can then start a Postgres server through the GUI of the app. If you go this route then you'll have to add "/Applications/Postgres.app/Contents/Versions/9.4/bin/" or the equivalent to your PATH in order to get the pg gem to build.

    * Through [Homebrew](http://brew.sh/):

      ```shell
      brew install postgresql
      ```

      **NOTE:**  When installed through homebrew, Postgres often requires additional configuration, see this [blog post](https://www.codefellows.org/blog/three-battle-tested-ways-to-install-postgresql) for instructions. You can then start the Postgresql server with

      ```shell
      pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
      ```

1. Install Redis. You can install this with [Homebrew](http://brew.sh/). Follow the instructions in the install output to start the redis server.

    ```shell
    brew install redis
    ```

    Run the redis server using command:
    ```
    redis-server --daemonize yes
    ```


#### Development Environment

1. Make sure you have Xcode installed

1. Install a Ruby manager - if you don't already have one, you will need a Ruby manager to install the appropriate Ruby release such as:
   * [RVM](https://rvm.io)
   * [Rbenv](https://github.com/rbenv/rbenv)
   * [chruby](https://github.com/postmodern/chruby)
   * or any other Ruby version manager that may come along

1. Use your ruby manager to install the necessary Ruby release. For instructions on this, please see the manager's documentation.

1. Make sure you have the Supermarket repo cloned to your machine, then change into that directory

    ```
    $ cd <supermarket-repo>
    ```

1. Then change into the src

    ```
    $ cd src/supermarket
    ```

1. Install Bundler gem
    ```
    gem install bundler:2.1.4 --user-install
    ```

1. Install required gems:
    ```
    bundle install
    ```
    N.B. you might get the following errors. Listing them with the fixes.
     - Error installing gem: ***mimemagic***
       - Fix-> `brew install shared-mime-info`

1. Create the database, migrate the database and seed the database:

    ```
    $ bundle exec rails db:setup
    ```

1. Add required Postgres extensions.

    ```
    $ psql supermarket_development -c 'create extension plpgsql'
    $ psql supermarket_development -c 'create extension pg_trgm'
    ```
    N.B. Ignore if the above 2 commands gives error: extenstion already exists.

1. Start the server:

    ```
    $ bundle exec foreman start
    ```

    N.B. ***If you receive errors, make sure that redis and Postgres are running.***

## Setting up Auth

Supermarket uses oc-id running on a Chef Infra Server to authenticate users to Supermarket.

IF YOU ARE AN INTERNAL CHEF STAFFER - there are some special things we need to do to set you up with oc-id. Consult the internal wiki on setting up your Supermarket dev environment (or ask a friendly team member!).

NOTE: Authentication currently requires a live Chef Infra Server running oc-id. We are working on a solution that would allow a developer to run the authentication locally. Stay tuned.

Create a new application and register it on oc-id (I called my application "Application:Supermarket Development"). Set the callback url to http://localhost:3000/auth/chef_oauth2/callback or whatever localhost domain you use.

In your local copy of the Supermarket repo, copy the .env file to .env.development. Open up .env.development and replace these values:

  ```
  CHEF_OAUTH2_APP_ID=YOUR_CHEF_OAUTH2_APP_ID
  CHEF_OAUTH2_SECRET=YOUR_CHEF_OAUTH2_SECRET
  ```
with these values:

  ```
  CHEF_OAUTH2_APP_ID=[Application ID of the oc-id application you just registered]
  CHEF_OAUTH2_SECRET=[Secret of the oc-id application you just registered]
  ```

Restart your foreman server.

Now when you click on "Sign In" you should be signed into your supermarket account with your Chef account!

NOTE: If you receive an omniauth csrf detected error, try clearing your browser's cache.

## SPDX license linking for cookbooks

If a cookbook that has licenseId which also happens to be a license mentioned in SPDX license list here - https://github.com/spdx/license-list-data/blob/master/json/licenses.json, need to be updated with respective licence url.

When a new cookbook is uploaded license url information is fetched from the above link and is updated.

For an existing implementation of supermarket there is a provision running some ctl commands to update this information for cookbooks already there in system.

Following commands are available to update the license urls for cookbooks :-
### Update licenses urls for all the cookbooks in system
`spdx-all`

### Update for a single cookbook
`spdx-latest <cookbook_name>`

### Update for a particular version of cookbook
`spdx-on-version <cookbook_name> <cookbook_version>`

## Connecting your GitHub Account

There are a couple features that depend on GitHub integration (CLA signing, some quality metrics in Fieri). You can set up an integration for your development environment by creating an application with your GitHub account. To do this:

1. Log into your GitHub account if you aren't already.
2. Click on your username in the upper right hand corner. This will bring you to your Profile page.
3. Click the "Edit Profile" button in the upper right corner of the Profile page.
4. Click on "Applications" in the vertical menu on the left hand side
5. At the top of the screen you'll see a section labeled "Developer applications" with a button that says "Register new Application."  Click on this button.
6. Name your application whatever you like (I use "Chef-Supermarket-Testing"), the set the homepage url as http://localhost:3000 (or whatever localhost domain that you use). Also set the Authorization callback URL to http://localhost:3000 (or your localhost domain of choice).
7. Click the "Register application" button.
8. Open up the .env.development file in your local copy of the Supermarket repo. Replace these values:

  ```
  GITHUB_KEY=YOUR_GITHUB_KEY
  GITHUB_SECRET=YOUR_GITHUB_SECRET
  ```

  with these values:

  ```
  GITHUB_KEY=[Your new application's client ID]
  GITHUB_SECRET=[Your new application's client secret]
  ```

Next, create a GitHub Access token. You also do this from the "Applications" section of your Profile page.

1. Look at the "Personal access tokens section heading." Click on the "Generate new token" button.
2. When prompted, enter your GitHub password.
3. Enter whatever you like for the Token description, I use "testing-supermarket"
4. Leave the scopes at the defaults
5. Click the "Generate token" button
6. Copy the token it generates and put it somewhere safe!
7. Open up your .env.development file again and replace this value:

  ```
  GITHUB_ACCESS_TOKEN=YOUR_GITHUB_ACCESS_TOKEN
  ```

  with this value:

  ```
  GITHUB_ACCESS_TOKEN=[Token you just generated through GitHub]
  ```

## Connecting your GitHub Enterprise Account

There are a couple features that depend on GitHub Enterprise integration (CLA signing, some quality metrics in Fieri). You can set up an integration for your development environment by creating an application with your GitHub Enterprise account. To do this:

1. Log into your GitHub Enterprise account if you aren't already.
2. Click on your username in the upper right hand corner.
3. Click the "User settings" in the vertical menu on the right corner. This will bring you to your Public Profile page.
4. Click on "Developer settings" in the vertical menu on the left hand side
5. At the top of the screen you'll see a section labeled "Developer settings" with text "OAuth App"  Click on this.
6. Click on button "new OAuth App". This will bring you to Register a new OAuth application page.
7. Name your application whatever you like (I use "testing-supermarket-app"), the set the homepage url as http://localhost:3000 (or whatever localhost domain that you use). Also set the Authorization callback URL to http://localhost:3000/auth/github/callback (or your localhost domain of choice).
8. Click the "Register application" button.
9. Open up the .env.development file in your local copy of the Supermarket repo. Replace these values:

  ```
  GITHUB_KEY=YOUR_GITHUB_KEY
  GITHUB_SECRET=YOUR_GITHUB_SECRET
  GITHUB_ENTERPRISE_URL=YOUR_GITHUB_ENTERPRISE_URL
  GITHUB_CLIENT_OPTION_SITE=YOUR_GITHUB_ENTERPRISE_SITE
  GITHUB_CLIENT_OPTION_AUTHORIZE_URL=YOUR_GITHUB_ENTERPRISE_AUTHORIZE_URL
  GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL=YOUR_GITHUB_ENTERPRISE_ACCESS_TOKEN_URL
  ```

  with these values:

  ```
  GITHUB_KEY=[Your new application's client ID]
  GITHUB_SECRET=[Your new application's client secret]
  GITHUB_ENTERPRISE_URL=[Your GitHub Enterprise URL]
  GITHUB_CLIENT_OPTION_SITE=YOURGITHUBENTERPRISEURL/api/v3
  GITHUB_CLIENT_OPTION_AUTHORIZE_URL=YOURGITHUBENTERPRISEURL/login/oauth/authorize
  GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL=YOURGITHUBENTERPRISEURL/login/oauth/access_token
  ```

Next, create a GitHub Access token. You also do this from the "Developer settings" section.

1. Click on "Personal access tokens". This will bring you to Personal access tokens page.
2. Look at the "Personal access tokens section heading." Click on the "Generate new token" button.
3. When prompted, enter your GitHub password.
4. Enter whatever you like for the Token description, I use "testing-supermarket"
5. Leave the scopes at the defaults
6. Click the "Generate token" button
7. Copy the token it generates and put it somewhere safe!
8. Open up your .env.development file again and replace this value:

  ```
  GITHUB_ACCESS_TOKEN=YOUR_GITHUB_ACCESS_TOKEN
  ```

  with this value:

  ```
  GITHUB_ACCESS_TOKEN=[Token you just generated through GitHub]
  ```

## Tests

Requirements for tests: PhantomJS 1.8, Node

Run the entire test suite (rspec, rubocop and mocha) with:

```
$ bundle exec rake spec:all
```

### Acceptance Tests

Acceptance tests are run with [Capybara](https://github.com/jnicklas/capybara). Run `rake spec:features` to run the specs in spec/features. The default `rake spec` also runs these.

When writing feature specs, the Rack::Test driver is used by default. If the Poltergeist driver is required to be used (for example, an acceptance test that uses AJAX), add the `use_poltergeist: true` metadata to the spec. See [the remove_members_from_ccla_spec.rb spec](https://github.com/chef/supermarket/blob/main/spec/features/remove_members_from_ccla_spec.rb#L17) for an example.

Some specs run using [PhantomJS](http://phantomjs.org/), which must be installed for the test suite to pass.

### JavaScript Tests

The JavaScript specs are run with [Karma](http://karma-runner.github.io) and use the [Mocha](http://mochajs.org/) test framework and the [Chai Assertion Library](http://chaijs.com/)

The specs live in spec/javascripts. Run `rake spec:javascripts` to run the specs, and `rake spec:javascripts:watch` to run them continuously and watch for changes.

[Node.js](http://nodejs.org/) is required to run the JavaScript tests.

## Background Jobs

[Read about Supermarket's background jobs in the wiki](https://github.com/chef/supermarket/wiki/Background-Jobs).

## Feature Flags

Supermarket uses a `.env` file to configure itself. Inside this file are key/value pairs. These key/value pairs will be exported as environment variables when the app runs, and Supermarket will look for these keys as environment variables when it needs to read a value that's configurable.

One of these keys is called `FEATURES` and it controls a number of features that can be turned on and off. Here are the available features that can be toggled:

* tools
* fieri
* announcement
* github
* no_crawl

Deprecated Features

CLA signing still works, but has been disabled in the public site in favor of [the DCO process](https://github.com/chef/chef/blob/main/CONTRIBUTING.md#developer-certification-of-origin-dco) which tracked outside of Supermarket.

* cla
* join_ccla

## License

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Copyright:**       | Copyright (c) Chef Software, Inc.
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
