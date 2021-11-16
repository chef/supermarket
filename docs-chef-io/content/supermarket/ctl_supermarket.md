+++
title = "supermarket-ctl (executable)"
draft = false
gh_repo = "supermarket"
aliases = ["/ctl_supermarket.html", "/ctl_supermarket/"]

[menu]
  [menu.supermarket]
    title = "supermarket-ctl"
    identifier = "supermarket/reference/supermarket-ctl"
    parent = "supermarket/reference"
    weight = 10
+++

{{% ctl_supermarket_summary %}}

## make-admin

The `make-admin` subcommand is used to make the named Chef Supermarket user an administrator.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl make-admin USER_NAME
```

where `USER_NAME` represents the name of the user to be granted administrator privileges.

## spdx

The `spdx` subcommands are used to manage SPDX license information in cookbooks. Linked SPDX licenses appear on the cookbook information page.

[The Software Package Data Exchange](https://spdx.dev/) (SPDX) is an open standard for software manifests, including components, licenses, copyrights, and security content.

SPDX maintains a [License List](https://spdx.org/licenses/) of common licenses and exceptions used in open source development. Changes to the SPDX License List are not automatically reflected in your cookbooks. to To apply changes made by SPDX, rescan your cookbooks with the `spdx` subcommands.

### spdx-all

The `spdx-all` command links the licenses known to SPDX for all cookbooks in your system.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl spdx-all
```

### spdx-latest

The `spdx-latest` command links the licenses known to SPDX for the specified cookbook.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl spdx-latest COOKBOOK_NAME
```

Where COOKBOOK_NAME is the name of cookbook for SPDX linking. The latest version of the cookbook receives SPDX linking.

### spdx-on-version

The `spdx-on-version` command links the licenses known to SPDX for the specified cookbook version.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl spdx-on-version COOKBOOK_NAME VERSION
```

Where COOKBOOK_NAME is the name of cookbook and VERSION is the version of the cookbook that receives SPDX linking.

## Quality Metrics

### qm-flip-admin-only

The `qm-flip-admin-only` command is used to make a single named quality
metric visible only to admins.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-flip-admin-only "METRIC_NAME"
```

where `METRIC_NAME` is the name of the quality metric to make admin only. Names containing spaces must be surrounded by quotes.

### qm-flip-all-admin-only

The `qm-flip-all-admin-only` command is used to make all quality metrics visible only to admins.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-flip-all-admin-only
```

### qm-flip-all-public

The `qm-flip-all-public` command is used to make all quality metrics visible to all users.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-flip-all-public
```

### qm-flip-public

The `qm-flip-public` command is used to make a single named quality
metric visible to all users.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-flip-public "METRIC_NAME"
```

where `METRIC_NAME` is the name of the quality metric to make public. Names containing spaces must be surrounded by quotes.

### qm-list

The `qm-list` command is used to list the names of quality metrics defined currently in a Supermarket.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-list
```

### qm-run-all-the-latest

The `qm-run-all-the-latest` command is used to run all quality metrics on the latest versions of all cookbooks.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-run-all-the-latest
```

### qm-run-on-latest

The `qm-run-on-latest` command is used to run all quality metrics on the latest version of a named cookbook.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-run-on-version COOKBOOK_NAME
```

where `COOKBOOK_NAME` is the name of the cookbook on which to run all quality metrics on its latest version.

### qm-run-on-version

The `qm-run-on-version` command is used to run all quality metrics on a given version of a named cookbook.

This subcommand has the following syntax:

```bash
sudo -u supermarket supermarket-ctl qm-run-on-version COOKBOOK_NAME VERSION
```

where `COOKBOOK_NAME` and `VERSION` are respectively the name and version of the cookbook on which to run all quality metrics.

## General Commands

### cleanse

The `cleanse` subcommand is used to re-set the server to the state it was in before the first time the `reconfigure` subcommand is run to destroy all data, configuration files, and logs.

This subcommand has the following syntax:

```bash
supermarket-ctl cleanse
```

### help

The `help` subcommand is used to print a list of all available supermarket-ctl commands.

This subcommand has the following syntax:

```bash
supermarket-ctl help
```

### reconfigure

The `reconfigure` subcommand is used when changes are made to the
supermarket.rb file to reconfigure the server. When changes are made to
the supermarket.rb file, they will not be applied to the Chef
Supermarket configuration until after this command is run. This
subcommand will also restart any services for which the
`service_name['enable']` setting is set to `true`.

This subcommand has the following syntax:

```bash
supermarket-ctl reconfigure
```

### show-config

The `show-config` subcommand is used to view the configuration that will be generated by the `reconfigure` subcommand. This command is most useful in the early stages of a deployment to ensure that everything is built properly prior to installation.

This subcommand has the following syntax:

```bash
supermarket-ctl show-config
```

### uninstall

The `uninstall` subcommand is used to remove the Chef Supermarket application, but without removing any of the data. This subcommand will shut down all services (including the `runit` process supervisor).

This subcommand has the following syntax:

```bash
supermarket-ctl uninstall
```

{{< note >}}

To revert the `uninstall` subcommand, run the `reconfigure` subcommand (because the `start` subcommand is disabled by the `uninstall` command).

{{< /note >}}

## Service Subcommands

{{% ctl_common_service_subcommands %}}

### hup

The `hup` subcommand is used to send a `SIGHUP` to all services. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl hup name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand.

### int

The `int` subcommand is used to send a `SIGINT` to all services. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl int name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand.

### kill

The `kill` subcommand is used to send a `SIGKILL` to all services. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl kill name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand.

### once

The supervisor for Chef Supermarket is configured to restart any service that fails, unless that service has been asked to change its state. The `once` subcommand is used to tell the supervisor to not attempt to restart any service that fails.

This command is useful when troubleshooting configuration errors that prevent a service from starting. Run the `once` subcommand followed by the `status` subcommand to look for services in a down state and/or to identify which services are in trouble. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl once name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand.

### restart

The `restart` subcommand is used to restart all services enabled on Chef Supermarket or to restart an individual service by specifying the name of that service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl restart name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand. When a service is successfully restarted the output should be similar to:

```bash
ok: run: service_name: (pid 12345) 1s
```

### service-list

The `service-list` subcommand is used to display a list of all available services. A service that is enabled is labeled with an asterisk (\*).

This subcommand has the following syntax:

```bash
supermarket-ctl service-list
```

### start

The `start` subcommand is used to start all services that are enabled in Chef Supermarket. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl start name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand. When a service is successfully started the output should be similar to:

```bash
ok: run: service_name: (pid 12345) 1s
```

The supervisor for Chef Supermarket is configured to wait seven seconds for a service to respond to a command from the supervisor. If you see output that references a timeout, it means that a signal has been sent to the process, but that the process has yet to actually comply. In general, processes that have timed out are not a big concern, unless they are failing to respond to the signals at all. If a process is not responding, use a command like the `kill` subcommand to stop the process, investigate the cause (if required), and then use the `start` subcommand to re-enable it.

### status

The `status` subcommand is used to show the status of all services available to Chef Supermarket. The results will vary based on the configuration of a given server. This subcommand has the following syntax:

```bash
supermarket-ctl status
```

and will return the status for all services. Status can be returned for individual services by specifying the name of the service as part of the command:

```bash
supermarket-ctl status name_of_service
```

where `name_of_service` represents the name of any service that is
listed after running the `service-list` subcommand.

When service status is requested, the output should be similar to:

```bash
run: service_name: (pid 12345) 12345s; run: log: (pid 1234) 67890s
```

where

- `run:` is the state of the service (`run:` or `down:`)
- `service_name:` is the name of the service for which status is
    returned
- `(pid 12345)` is the process identifier
- `12345s` is the uptime of the service, in seconds

For example:

```bash
down: actions: (pid 35546) 10s
```

By default, runit will restart services automatically when the services fail. Therefore, runit may report the status of a service as `run:` even when there is an issue with that service. When investigating why a particular service is not running as it should be, look for the services with the shortest uptimes. For example, the list below indicates that the **actions** should be investigated further:

```bash
run: actions: (pid 6361) 4132s; run: log: (pid 6173) 4146s
run: actions_consumer: (pid 6374) 5s; run: log: (pid 6227) 4139s
run: actions_messages: (pid 6392) 4131s; run: log: (pid 6324) 4133s
run: memcached: (pid 6115) 4157s; run: log: (pid 6129) 4156s
```

#### Log Files

A typical status line for a service that is running in Chef Supermarket is similar to the following:

```bash
run: name_of_service: (pid 1486) 7819s; run: log: (pid 1485) 7819s
```

where:

- `run` describes the state in which the supervisor attempts to keep processes. This state is either `run` or `down`. If a service is in a `down` state, it should be stopped
- `name_of_service` is the service name
- `(pid 1486) 7819s;` is the process identifier followed by the amount of time (in seconds) the service has been running
- `run: log: (pid 1485) 7819s` is the log process. It is typical for a log process to have a longer run time than a service; this is because the supervisor does not need to restart the log process in order to connect the supervised process

If the service is down, the status line will appear similar to the following:

```bash
down: actions: 3s, normally up; run: log: (pid 1485) 8526s
```

where

- `down` indicates that the service is in a down state
- `3s, normally up;` indicates that the service is normally in a run state and that the supervisor would attempt to restart this service after a reboot

### stop

The `stop` subcommand is used to stop all services enabled on Chef Supermarket. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl stop name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand. When a service is successfully stopped the output should be similar to:

```bash
ok: diwb: service_name: 0s, normally up
```

For example:

```bash
supermarket-ctl stop
```

will return something similar to:

```bash
ok: down: actions: 1s, normally up
ok: down: actions_consumer: 0s, normally up
ok: down: actions_messages: 0s, normally up
ok: down: memcached: 1s, normally up
```

### tail

The `tail` subcommand is used to follow all Chef Supermarket logs for all services. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl tail name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand.

### term

The `term` subcommand is used to send a `SIGTERM` to all services. This command can also be run for an individual service by specifying the name of the service in the command.

This subcommand has the following syntax:

```bash
supermarket-ctl term name_of_service
```

where `name_of_service` represents the name of any service that is listed after running the `service-list` subcommand.
