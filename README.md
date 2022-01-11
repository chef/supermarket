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

The code is designed to be easy for others to contribute. The goal of the **README** file is to familiarize you with the project. You can find detailed information about Supermarket at [Wiki](https://github.com/chef/supermarket/wiki) page. You can also [follow the project development in ZenHub](https://app.zenhub.com/workspaces/supermarket-60cbda5a95f583001207255f).

If you want to contribute to **Supermarket**, read the [contributor's workflow](https://github.com/chef/supermarket/blob/main/CONTRIBUTING.md) for license information and other helpful tips that aid you in getting started. There are project artifacts such as planning docs, wireframes, recorded demos, and team retrospectives at [public Google Drive folder](https://drive.google.com/a/gofullstack.com/#folders/0B6WV7Qy0ZCUfbFFPNG9CejExUW8).

If you have questions, feature ideas, or other suggestions, please [open a GitHub Issue](https://github.com/chef/supermarket/issues/new).

This repository has the code for the **Supermarket** application and the omnibus definition used to build the `deb/rpm` packages. Other Supermarket related repositories are:

* [chef-cookbooks/supermarket-omnibus-cookbook](https://github.com/chef-cookbooks/supermarket-omnibus-cookbook): This cookbook is used to deploy Supermarket through the Supermarket omnibus package. For details on using this cookbook to install Supermarket omnibus, check out [this webinar by the Supermarket Engineering team](https://www.chef.io/webinars/?commid=164925).

## Requirements

* Ruby 2.7.5
* PostgreSQL 9.3
* Redis 6.2.5

## Development

### Configuration

Configure the [dotenv](https://github.com/bkeepers/dotenv) keys and secrets. See `.env.example` for required keys and secrets. [`docs/CONFIGURING.md`](https://github.com/chef/supermarket/blob/main/src/supermarket/docs/CONFIGURING.md) page details the *not-so-straightforward configuration* information required to setup Supermarket working locally.

### Local Environment

These instructions are tested and verified on macOS Catalina (10.15).

#### Dependency Services

##### As Docker Containers

1. Install `docker`

    ```shell
    brew cask install docker
    ```

  Ensure you have a *PostgreSQL* version installed on the local filesystem for development libraries to be available for building the `pg` gem. See the instructions for locally running *PostgreSQL* below, however omit the steps where the service is running.

1. Start the docker containers.

    ```shell
    cd src/supermarket
    docker-compose up
    ```

##### As Locally Running Processes

1. Install *Postgres* by following any of the below instructions:

    * Install the [Postgres App](http://postgresapp.com/):

      This is probably the simplest way to get *Postgres* running on your mac.  You can then start a *Postgres* server through the GUI of the app. If you go this route, then you'll have to add `/Applications/Postgres.app/Contents/Versions/9.4/bin/` or the equivalent path to obtain the *pg gem* to build.

    * Through [Homebrew](http://brew.sh/):

      ```shell
      brew install postgresql
      ```

     When installed through homebrew, *Postgres* often requires additional configuration, see this [blog post](https://www.codefellows.org/blog/three-battle-tested-ways-to-install-postgresql) for instructions. Ensure to start the *Postgresql* server by following the command given below.

      ```shell
      pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
      ```


1. Install *Redis*. You can install it with [Homebrew](http://brew.sh/). Follow the instructions in the install output to start the *redis* server.

    ```shell
    brew install redis
    ```

    Run the *redis* server using command:

    ```shell
    redis-server --daemonize yes
    ```

#### Development Environment

1. Ensure you have *Xcode* installed.

1. Install a Ruby manager. If you don't already have one, you will need a *Ruby manager* to install the appropriate Ruby release, such as:
   * [RVM](https://rvm.io)
   * [Rbenv](https://github.com/rbenv/rbenv)
   * [chruby](https://github.com/postmodern/chruby)
   * or any other Ruby version manager that may come along.

1. Use your ruby manager to install the necessary *Ruby* release. For instructions on this, please see the manager's documentation.

1. Ensure you have the *Supermarket* repo cloned to your machine. If not, clone it.
1. Navigate to that directory.

    ```shell
    cd <supermarket-repo>
    ```

1. Again, navigate to the *src* folder.

    ```shell
    cd src/supermarket
    ```

1. Install *Bundler* gem.

    ```shell
    gem install bundler:2.1.4 --user-install
    ```

1. Install required gems:

    ```shell
    bundle install
    ```

    {{< note >}}
    You might encounter the following errors. The possible fixes are also provided herewith.
     * Error installing gem: ***ruby-filemagic***
     * Fix -> `brew install libmagic`
     * Error installing gem: ***mimemagic***
     * Fix-> `brew install shared-mime-info`
     {{< /note >}}

1. Create the database, migrate to it, and then seed the database:

    ```shell
    bundle exec rails db:setup
    ```

1. Add required *Postgres* extensions.

    ```shell
    psql supermarket_development -c 'create extension plpgsql'
    psql supermarket_development -c 'create extension pg_trgm'
    ```

    {{< note >}}
    Ignore if the above 2 commands displays error: extenstion already exists.
    {{< /note >}}

1. Start the server:

    ```shell
    bundle exec foreman start
    ```

    {{< note >}}
    If you receive errors, ensure that *redis* and *Postgres* are running.
    {{< /note >}}

## Setting up Auth

Supermarket uses *oc-id* running on a Chef Infra Server to authenticate users to Supermarket.

IF YOU ARE AN INTERNAL CHEF STAFFER - We will be performing some settings prior to set you up with *oc-id*. Consult the internal wiki on setting up your Supermarket dev environment (or ask a friendly team member!).

{{< note >}}
Authentication currently requires a live Chef Infra Server running *oc-id*. We are working on a solution that would allow a developer to run the authentication locally. Stay tuned.
{{< /note >}}

Create a new application and register it on *oc-id* (I called my application **Application:Supermarket Development**). Set the callback URL to <http://localhost:3000/auth/chef_oauth2/callback> or whatever localhost domain you use.

In your local copy of the *Supermarket* repo, copy the `.env` file to `.env.development`. Open up `.env.development` and replace these values:

  ```shell
  CHEF_OAUTH2_APP_ID=YOUR_CHEF_OAUTH2_APP_ID
  CHEF_OAUTH2_SECRET=YOUR_CHEF_OAUTH2_SECRET
  ```

with these values:

  ```shell
  CHEF_OAUTH2_APP_ID=[Application ID of the oc-id application you just registered]
  CHEF_OAUTH2_SECRET=[Secret of the oc-id application you just registered]
  ```

Restart your *foreman* server.

Now, when you click **Sign In**, you will be taken to your supermarket account with your Chef account!

{{< note >}}
If you receive an omniauth csrf detected error, try clearing your browser's cache.
{{< /note >}}

## SPDX license linking for cookbooks

If a cookbook that has *licenseId*, which is also mentioned in *SPDX license* listed at <https://github.com/spdx/license-list-data/blob/master/json/licenses.json>, you need to update with respective licence URL.

When a new cookbook is uploaded, license url information is fetched from the above link and is updated.

For an existing implementation of supermarket, there is a provision running with some *ctl* commands, for updating the information for cookbooks already there in system.

Following commands are available to update the license URLs for cookbooks:

### Update licenses URLs for all the cookbooks in the system

`spdx-all`

### Update for a single cookbook

`spdx-latest <cookbook_name>`

### Update for a particular version of a cookbook

`spdx-on-version <cookbook_name> <cookbook_version>`

## Connecting your GitHub Account

There are a couple of features that depend on GitHub integration (CLA signing, some quality metrics in Fieri) with your development environment. Follow these steps to create an application with your Github account:

1. Log into your Github account.
1. Click on your **username** in the upper right-hand corner. Your Profile page appears.
1. Click the **Edit Profile** button in the upper right corner of the Profile page.
1. Click **Applications** from the vertical menu on the left-hand side.
1. Click the **Register new Application** button from the section labeled **Developer applications** at the top of the screen.
1. Specify the name of your application (For example, *Chef-Supermarket-Testing*), then set the homepage URL as <http://localhost:3000> (or whatever localhost domain that you use).
1. Set the *Authorization callback URL* to `http://localhost:3000` (or your localhost domain of choice).
1. Click the **Register application** button.
1. Open the `.env.development` file in your local copy of the *Supermarket repo*.
1. Replace these values:

  ```shell
  GITHUB_KEY=YOUR_GITHUB_KEY
  GITHUB_SECRET=YOUR_GITHUB_SECRET
  ```

  with:

  ```shell
  GITHUB_KEY=[Your new application's client ID]
  GITHUB_SECRET=[Your new application's client secret]
  ```

1. Next, create a *Github Access* token. You can also do this from the **Applications** section of your **Profile** page.

1. Navigate to the **Personal access tokens** section.
1. Click the **Generate new token** button.
1. When prompted, enter your **Github password**.
1. Enter the **Token description**. For example, *testing-supermarket*.
1. Leave the scopes at the defaults.
1. Click the **Generate token** button.
1. Copy the token generated and secure it safe!.
1. Open up your `.env.development` file again.
1. Replace this value:

  ```shell
  GITHUB_ACCESS_TOKEN=YOUR_GITHUB_ACCESS_TOKEN
  ```

  with:


  ```shell
  GITHUB_ACCESS_TOKEN=[Token you just generated through Github]
  ```

## Connecting your GitHub Enterprise Account

There are a couple of features that depend on GitHub Enterprise integration (CLA signing, some quality metrics in Fieri) withyour development environment. Follow these steps to create an application with your Github account::

1. Log into your Github Enterprise account.
1. Click on your **username** in the upper right-hand corner.
1. Click **User settings** in the vertical menu on the right corner. Your public Profile page appears.
1. Click **Developer settings** in the vertical menu on the left-hand side.
1. Click the section labeled **Developer settings** with text *OAuth App* at the top of the screen.
1. Click **new OAuth App**. You can now register to a new *OAuth application* page.
1. Specify the name of your application. (For example, *testing-supermarket-app*), then set the homepage URL as <http://localhost:3000> (or whatever localhost domain that you use).
1. Set the **Authorization callback URL** to <http://localhost:3000/auth/github/callback> (or your localhost domain of choice).
1. Click the **"**Register application** button.
1. Open up the `.env.development` file in your local copy of the *Supermarket repo*.
1. Replace these values:

  ```shell
  GITHUB_KEY=YOUR_GITHUB_KEY
  GITHUB_SECRET=YOUR_GITHUB_SECRET
  GITHUB_ENTERPRISE_URL=YOUR_GITHUB_ENTERPRISE_URL
  GITHUB_CLIENT_OPTION_SITE=YOUR_GITHUB_ENTERPRISE_SITE
  GITHUB_CLIENT_OPTION_AUTHORIZE_URL=YOUR_GITHUB_ENTERPRISE_AUTHORIZE_URL
  GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL=YOUR_GITHUB_ENTERPRISE_ACCESS_TOKEN_URL
  ```

  with:

  ```shell
  GITHUB_KEY=[Your new application's client ID]
  GITHUB_SECRET=[Your new application's client secret]
  GITHUB_ENTERPRISE_URL=[Your GitHub Enterprise URL]
  GITHUB_CLIENT_OPTION_SITE=YOURGITHUBENTERPRISEURL/api/v3
  GITHUB_CLIENT_OPTION_AUTHORIZE_URL=YOURGITHUBENTERPRISEURL/login/oauth/authorize
  GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL=YOURGITHUBENTERPRISEURL/login/oauth/access_token
  ```

1. Next, create a **GitHub Access** token. You also do this from the **Developer settings** section.

1. Click **Personal access tokens**. The *Personal access tokens* page appears.
1. Navigate to the **Personal access tokens** section.
1. Click the **Generate new token** button.
1. When prompted, enter your **GitHub password**.
1. Enter the **Token description**. For example, *testing-supermarket*.
1. Leave the scopes at the defaults.
1. Click the **Generate token** button.
1. Copy the token generated and secure it safe!.
1. Open up your `.env.development` file again.
1. Replace this value:

  ```shell
  GITHUB_ACCESS_TOKEN=YOUR_GITHUB_ACCESS_TOKEN
  ```

  with:

  ```shell
  GITHUB_ACCESS_TOKEN=[Token you just generated through Github]
  ```

## Tests

Requirements for tests: PhantomJS 1.8, Node.

Run the entire test suite (rspec, rubocop and mocha) with:

```shell
bundle exec rake spec:all
```

### Acceptance Tests

Acceptance tests are run with [Capybara](https://github.com/jnicklas/capybara). Run `rake spec:features` to run the specs in `spec/features`. The default `rake spec` also runs these.

When writing feature specs, the *Rack::Test* driver is used by default. If the *Poltergeist* driver is required to be used (for example, an acceptance test that uses AJAX), add the `use_poltergeist: true` metadata to the spec. See [the remove_members_from_ccla_spec.rb spec](https://github.com/chef/supermarket/blob/main/spec/features/remove_members_from_ccla_spec.rb#L17) for an example.

Some specs run using [PhantomJS](http://phantomjs.org/), which must be installed for the test suite to pass.

### JavaScript Tests

The JavaScript specs are run with [Karma](http://karma-runner.github.io) and use the [Mocha](http://mochajs.org/) test framework and the [Chai Assertion Library](http://chaijs.com/).

The specs live in `spec/javascripts`. Run `rake spec:javascripts` to run the specs, and `rake spec:javascripts:watch` to run them continuously and watch for changes.

[Node.js](http://nodejs.org/) is required to run the JavaScript tests.

## Background Jobs

[Read about Supermarket's background jobs in the wiki](https://github.com/chef/supermarket/wiki/Background-Jobs).

## Feature Flags

*Supermarket* uses a `.env` file to configure itself. Inside this file are *key/value* pairs. These *key/value* pairs will be exported as environment variables when the app runs, and *Supermarket* looks for these keys as environment variables when it needs to read a value that's configurable.

One of these keys is called `FEATURES` and it controls a number of features that can be turned on and off. Here are the available features that can be toggled:

* tools
* fieri
* announcement
* github
* no_crawl

## Deprecated Features

CLA signing still works but has been disabled in the public site in favor of [the DCO process](https://github.com/chef/chef/blob/main/CONTRIBUTING.md#developer-certification-of-origin-dco), which tracked outside of Supermarket.

* cla
* join_ccla

## License

|                        |                                           |
|:---------------------: |:-----------------------------------------:|
| **Copyright:**         | Copyright (c) Chef Software, Inc.         |
| **License:**           | Apache License, Version 2.0               |

```text
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and
limitations under the License.
```
