Super Market [![Code Climate](https://codeclimate.com/github/opscode/supermarket.png)](https://codeclimate.com/github/opscode/supermarket) [![Build Status](https://travis-ci.org/opscode/supermarket.png?branch=master)](https://travis-ci.org/opscode/supermarket) [![Dependency Status](https://gemnasium.com/opscode/supermarket.png)](https://gemnasium.com/opscode/supermarket) [![Coverage Status](https://coveralls.io/repos/opscode/supermarket/badge.png?branch=master)](https://coveralls.io/r/opscode/supermarket?branch=master)
===========

Super Market is Chef's new community project. Here is a rough roadmap that corresponds to the main outcomes we hope to achieve through improving the Chef community experience:

- Better facilitation for signing and managing Contribor License Agreements (CLA). [#2](https://github.com/opscode/supermarket/issues?milestone=2&state=open)
- Exposing API endpoints for accessing community member and contributor status for other services to consume. [#2](https://github.com/opscode/supermarket/issues?milestone=2&state=open)
- Storing community member information and presenting it in a more user friendly and manageable way. [#2](https://github.com/opscode/supermarket/issues?milestone=2&state=open)
- Establishing a low barrier to entry for individuals to contribute and improve the community experience. [#2](https://github.com/opscode/supermarket/issues?milestone=2&state=open)
- Providing capabalities for trusted community members to moderate the community contributions. [#3](https://github.com/opscode/supermarket/issues?milestone=3&state=open)
- Improving the Cookbooks API to provide more relevant information about individual cookbooks. [#3](https://github.com/opscode/supermarket/issues?milestone=3&state=open)
- Better organized documentation for various Chef projects. [#4]
- Chef Server cookbook API. [#4]
- Dependency API. [#4]
- Incorporating other community contributions like knife plugins, ohai plugins, and related Chef packages. [#5]
- Improved Cookbook ratings using automatic multifactor metascore instead of voting. [#6]


Project Status
--------------

This project is currently in heavy active development and is a pre-release.


Contributing
------------

We'd love for you to be involved. Read the [contributor's workflow](https://github.com/opscode/supermarket/blob/master/CONTRIBUTING.md) for license information and helpful tips before you get started.

You can view the prioritized tasks in [Super Market's public Pivotal Tracker project](https://www.pivotaltracker.com/s/projects/984852). Please include a link to the story (or Story ID) if there is one in your pull requests.

There are also some project artifacts such as planning docs, wireframes, recorded demos, and team retrospectives in a [public Google Drive folder](https://drive.google.com/a/cramerdev.com/#folders/0B6WV7Qy0ZCUfbFFPNG9CejExUW8).

If you have questions, feature ideas, or other suggestions, please [create a Github Issue](https://github.com/opscode/supermarket/issues?state=open) and we'll respond in a timely manner. If you include the "Feature", "Enhancement", or "Bug" labels when creating a new issue, a Pivotal Tracker story will be automatically created in the icebox.


Continuous Integration
------------
Super Market is using Travis CI. [View build info](https://travis-ci.org/opscode/supermarket)


OmniAuth
--------

Super Market uses [OmniAuth](https://github.com/intridea/omniauth) for
authentication. The OmniAuth configuration is data-driven, so you can configure
OmniAuth to use whatever authentication method your organization desires. You
can read more about OmniAuth on the [OmniAuth GitHub
page](https://github.com/intridea/omniauth). In short, you need to create and
register Super Market as an application and setup the keys in the `.env` file.

To register GitHub as an OmniAuth sign in method:

1. [Register your application](https://github.com/settings/applications/new)
2. Make sure the Authorization callback URL has the app's URL with the /auth/github/callback path
3. Add the following to your `.env`:

  ```yaml
  GITHUB_KEY: MY_KEY
  GITHUB_SECRET: MY_SECRET
  ```

where `MY_KEY` and `MY_SECRET` are the values given when you created the application.

You can register Twitter as a provider by creating an application on the [Twitter Developers site](https://dev.twitter.com/apps).

### Adding Additional Providers

You can add support for additional OAUTH providers by creating an extractor object in `app/extractors`.

Since each OmniAuth provider returns a different set of information, you often end up with nested case statements to account for all the different providers. Super Market accounts for this behavior using Extractor objects. Each OmniAuth provider must have an associated Extractor object that extracts the correct information from the OmniAuth response hash into a object with a unified interface.

### lvh.me

Twitter and other OmniAuth providers do _not_ like localhost URLs as callback URLs. Thankfully, there's a special DNS entry, `lvh.me`, that will resolve to localhost. It is recommended that you register your OmniAuth callbacks with `lvh.me:3000` and always browse to `lvh.me` instead of `localhost:3000`.

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

The specs live in spec/javascripts. Run `rake spec:javascripts` to run the specs, and `rake spec:javascripts:watch` to run them continuously and watch for changes.

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


Development
-----------
### Using the Development VM (recommended for new users)
Supermarket includes a collection of Chef cookbooks and a preconfigured `Vagrantfile` that makes it easy to get up an running without modifying your local system.

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](http://downloads.vagrantup.com/)
1. Run the server:

        $ ./bin/supermarket server

By default, the VM uses NFS mounted folders, 4GB of RAM, and 2 CPUs. If you are constrained in any of these areas, you can override these defaults by specifying the environment variables:

        $ VM_MEMORY=2048 VM_CPUS=1 VM_NFS=false ./bin/supermarket server

**NOTE:** These variables must be set the _first_ time you run any supermarket command. After that, they will be persisted. To change them, you'll need to destroy the Vagrant machine (`vagrant destroy`) and run the command again.

If your operating system supports NFS mounted folders, you may be asked to supply your administrative password. Please note, sometimes VirtualBox explodes when trying to mount NFS shares (specifically on OSX Mavericks); although it will make the application significantly slower, disabling NFS folder sharing can alleviate an error like:

```text
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]

Stderr: 0%...
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to create the host-only adapter
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory

VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterface, interface IHostNetworkInterface
VBoxManage: error: Context: "int handleCreate(HandlerArg*, int, int*)" at line 68 of file VBoxManageHostonly.cpp
```

Running `sudo /Library/StartupItems/VirtualBox/VirtualBox restart` can help fix this problem, but sometimes you just can't use NFS mounts with VirtualBox.

### Using your local machine (advanced users only)

1. Install Ruby 2.0 (latest patch) using your favorite Ruby manager
1. Install Postgres (from [homebrew](http://brew.sh/) or the [app](http://postgresapp.com/))
1. Install bundler

        $ gem install bundler

1. Install required gems:

        $ bundle

1. Configure the [dotenv](https://github.com/bkeepers/dotenv) keys and secrets.  See `.env.example` for required keys and secrets to get up and running.

1. Run the migrations:

        $ ./bin/rake db:create && ./bin/rake db:migrate && ./bin/rake db:seed

1. Start the server:

        $ foreman start

Deployment
-----------
### Deploying with Chef

1. Upload the supermarket cookbook to your Chef server.

        $ knife upload supermarket -o path-to-supermarket-repo/chef/cookbooks

1. Bootstrap a server as a new node.

        $ knife bootstrap someserver.com -u some-user -N some-node

1. Within your node _you must_ set a postgres username, password, default database, devise secret key and a secret key base.

        {
          "postgres": {
            "user": "some-user",
            "password": "some-password",
            "database": "some-database"
          },
          "secret_key_base": "some-secret",
          "devise_secret_key": "some-secret"
        }

_You'll also most likely want to add other configuration to your node, reference `chef/cookbooks/templates/default/.env.erb`
for other environment variables that can be set._

1. Add the supermarket cookbook to your newly bootstraped nodes run list.

        $ knife node run_list add some-node 'recipe[supermarket]'

1. SSH into your node and run `chef-client` this will deploy supermarket.

        ssh some-user@someserver.com
        chef-client

