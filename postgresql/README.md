# PostgreSQL

This package wraps the [Chef Base Plans PostgreSQL Package](https://github.com/chef-base-plans/postgresql). More documentation can be found in the original package repository's [README](https://github.com/chef-base-plans/postgresql#readme) and the [PostgreSQL documentation](https://www.postgresql.org/docs/).

This document is to be used in addition to the previous two documents and will not cover PostgreSQL configurations or the package specifics in depth (such as bindings, topologies, update strategies), but will focus on the usage of the application package in the Supermarket context.

## Maintainers

* The Chef Maintainers <humans@chef.io>

## Type of Package

Service package

## Usage

This plan should be used by starting the service with:

```
$ hab [svc load|start] chef/supermarket-postgresql
```

And either binding rails/sidekiq to it (see "Binding" below) or providing the necessary parameters to the dependent services.

The package hooks will run as the `root:root` but will make use of the `process[user|group]` (`supermarket:supermarket` by default) in the configuration to run postgresql itself - this is due to included package functionality that will set kernel parameters.

## Bindings

Both the [rails/web package](src/supermarket/habitat-web) and the [sidekiq worker](src/supermarket/habitat-sidekiq) can consume this service through an optional bind named `database` using the `--bind` flag: 

```
hab svc load <origin>/<app> --bind database:supermarket-postgresql.default
```

Note when using the bind the package will attempt to connect to the database using `bind.database.first.sys.ip` which resolves to the public IP of the machine gathered by the Habitat Supervisor. This then has two requirements to work properly:

1. The `listen_addresses`/`md5_auth_cidr_addresses` must be set correctly: `listen_addresses` must contain an interface listening for external traffic, (i.e. _not just_ the loopback at `127.0.0.1`) and the CIDR for the source machine must exist in the auth addresses.
2. The machine must be able to receive traffic on the given address (see #1) and port. In the case of an AWS machine, for example, the security group must allow traffic on the specified port.

Note these apply even if the application is loaded on the same machine, as it will reach out publicly through the IP. For example, in the case of AWS, the security group should allow traffic on the specified port set to itself.

If desired, this can be modified in the future to check for the existence of the database host configuration value even if the bind exists. This may not be desired in all circumstances, so is not currently included.

More information regarding binds can be found in the Chef Base Plans documentation for PostgreSQL mentioned in the initial blurb.


## Configuration

Every available configuration item is given a reasonable default **but** for the superuser `name`/`password` which should be changed from the default. When `[data/log]_directory` are not specified, the habitat default service directories are used (`/hab/svc/<package-name>/data` and `/hab/svc/<package-name>/logs`).

Most of the configuration files are directly copied from the Chef Base Plans repository with additional values/configurations inserted for Supermarket specific defaults or to allow for additional items to be configured that were not configurable in the original package (such as data directory).
