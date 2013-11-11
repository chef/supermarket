Super Market
============
Super Market is Opscode's Individual Contributor License Agreement (ICLA) service. It performs a variety of functions including:

- Exposing an API for other services to consume
- Storing user-information and CLA status
- More...


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


Development
-----------
### Using the Development VM (recommended for new users)
Supermarket includes a collection of Chef cookbooks and a preconfigured `Vagrantfile` that makes it easy to get up an running without modifying your local system.

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](http://downloads.vagrantup.com/)
1. Run the server:

        $ ./bin/supermarket server

**Note:** The development VM makes certain assumptions (such as the port and mode you are running Rails on), which are not configurable at this time. _The Chef cookbooks and `Vagrantfile` are packaged with this repository are **not** designed for a production deployment!_

By default, the VM uses NFS mounted folders, 4GB of RAM, and 2 CPUs. If you are constrained in any of these areas, you can override these defaults by specifying the enviroment variables:

        $ VM_MEMORY=2048 VM_CPUS=1 VM_NFS=false ./bin/supermarket server

**NOTE:** These variables must be set the _first_ time you run any supermarket command. After that, they will be persisted. To change them, you'll need to destroy the Vagrant machine (`vagrant destroy`) and run the command again.

If your operating system supports NFS mounted folders, you may be asked to supply your administrative password. Please note, sometimes VirtualBox explodes when trying to mount NFS shares; although it will make the application significantly slower, disabling NFS folder sharing can alleviate an error like:

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

### Using your laptop (advanced users only)

1. Install Ruby 2.0 (latest patch) using your favorite Ruby manager
1. Install Postgres (from [homebrew](http://brew.sh/) or the [app](http://postgresapp.com/))
1. Install bundler

        $ gem install bundler

1. Install required gems:

        $ bundle

1. Run the migrations:

        $ ./bin/rake db:create && ./bin/rake db:migrate && ./bin/rake db:seed

1. Start the server:

        $ ./bin/rails server
