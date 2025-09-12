+++
title = "Upgrade Chef Supermarket"
date = 2021-12-28T11:04:48-08:00
draft = false
gh_repo = "supermarket"

[menu]
  [menu.supermarket]
    title = "Upgrades"
    identifier = "supermarket/server/upgrade.md"
    parent = "supermarket/server"
+++

This document explains how to upgrade Supermarket.

## Supported versions

Progress Chef supports Supermarket 5.0 and later. For more details about supported Chef Software, see the [supported versions documentation](/versions/#supported-free-distributions).

### PostgreSQL bundled with Supermarket

Supermarket is bundled with PostgreSQL.
The following table shows which version of PostgreSQL is bundled with each Supermarket version.

| Supermarket version    | PostgreSQL version |
|------------------------|--------------------|
| >= 4.2 and < 5.0       | 9.3                |
| >= 5.0 and < 5.2.0     | 13.4               |
| 5.2.0                  | 13.18              |
| >= 5.2.1               | 13.21              |

## Before you upgrade

Use these guidelines to choose the correct upgrade process:

- If you're upgrading from Supermarket 4.2.x to Supermarket 5.x, this also upgrades the version of PostgreSQL embedded with Supermarket. This process requires extra steps for managing the database and Supermarket configuration. Follow the [Upgrade to Supermarket 5.0 documentation](#upgrade-to-supermarket-42x-to-5x).

- If you want to upgrade from a version earlier than 4.2 to Supermarket 5.x, first upgrade to Supermarket 4.2.x using the [regular upgrade process](#upgrade-supermarket), then [upgrade to version 5.x](#upgrade-to-supermarket-42x-to-5x).

- For all other upgrades, follow the [regular upgrade process](#upgrade-supermarket).

## Upgrade Supermarket

To upgrade Supermarket, follow these steps:

1. Stop the Supermarket services:

    ```bash
    sudo supermarket-ctl stop
    ```

1. Back up the `/var/opt/supermarket` directory.
1. Download a Supermarket package from [Chef Downloads](https://www.chef.io/downloads).
1. Install the new package using your distribution's package manager:

    - For Ubuntu:

      ```bash
      dpkg -i /path/to/package/supermarket*.deb
      ```

    - For RHEL:

      ```bash
      rpm -Uvh /path/to/package/supermarket*.rpm
      ```

1. Start the Chef Supermarket services:

    ```bash
    sudo supermarket-ctl start
    ```

1. Reconfigure Chef Supermarket server:

    ```bash
    sudo supermarket-ctl reconfigure
    ```

1. After the upgrade finishes, restart the services that run Chef Supermarket to clear the old installation from server memory.

    ```bash
    systemctl list-units | grep runsvdir
    ```

1. Restart the unit:

    ```bash
    systemctl restart <UNIT_NAME>
    ```

    This restarts the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.

## Upgrade to Supermarket 4.2.x to 5.x

When you upgrade from Supermarket 4.2.x to 5.x, this also [upgrades PostgreSQL from 9.3 to 13.x](#postgresql-bundled-with-supermarket).
This process requires a one-time downtime to vacuum, upgrade, and re-index the database.

### Configure PostgreSQL in the Supermarket settings

Prepare for the upgrade:

1. In the `supermarket.rb` settings, set the `pg_upgrade_timeout` attribute to the intended timeout value in seconds.

    For example:

    ```rb
    default['supermarket']['postgresql']['pg_upgrade_timeout'] = <SECONDS>
    ```

    Set this value based on your data size.

1. Remove the `checkpoint-segments` attribute from your `supermarket.rb` settings:

    ```ruby
    # This setting is EOL in Supermarket 5.x and PostgreSQL 13
    # default['supermarket']['postgresql']['checkpoint_segments']
    ```

   PostgreSQL removed the `checkpoint_segments` attribute and we removed it from the Supermarket configuration.

### Prepare PostgreSQL embedded with Supermarket

Prepare the PostgreSQL database for upgrading:

1. Create a backup of the PostgreSQL databases:

    ```bash
    cd /
    sudo -u supermarket /opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump.sql
    ```

    **Important:** Always back up your PostgreSQL data before upgrading. Store a copy of the backup in a separate, safe location that is not on the Supermarket server. This ensures you can restore your data if anything goes wrong during the upgrade.

1. Vacuum the database:

    ```bash
    cd /
    sudo -u supermarket /opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
    ```

    This reduces the database size by deleting unnecessary data and speeds up the migration. Vacuuming takes about 1 to 2 minutes per gigabyte of data, depending on data complexity, and requires free disk space at least as large as your database.

    For more information, see the [`vacuumdb` documentation](https://www.postgresql.org/docs/13/app-vacuumdb.html).

### Upgrade Supermarket

To upgrade Supermarket, follow these steps:

1. Stop the Supermarket services:

    ```bash
    sudo supermarket-ctl stop
    ```

1. Back up the `/var/opt/supermarket` directory.

1. Download a Supermarket package from [Chef Downloads](https://www.chef.io/downloads).

1. Install the new package using your distribution's package manager:

    - For Ubuntu:

      ```bash
      dpkg -i /path/to/package/supermarket*.deb
      ```

    - For RHEL:

      ```bash
      rpm -Uvh /path/to/package/supermarket*.rpm
      ```

1. Reconfigure Chef Supermarket server:

    ```bash
    sudo supermarket-ctl reconfigure
    ```

1. After the upgrade finishes, restart the services that run Chef Supermarket to clear the old installation from server memory.

    ```bash
    systemctl list-units | grep runsvdir
    ```

1. Restart the unit:

    ```bash
    systemctl restart <UNIT_NAME>
    ```

    This restarts the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.

### Clean up the PostgreSQL database

Follow these steps to remove the old PostgreSQL installation and clear the cache:

1. Stop Supermarket:

    ```bash
    sudo supermarket-ctl stop
    ```

1. Start the newly installed PostgreSQL server:

    ```bash
    sudo supermarket-ctl start postgresql
    ```

1. Reindex the PostgreSQL database:

    ```bash
    sudo -u supermarket /opt/supermarket/embedded/bin/reindexdb --all -p 15432
    ```

    [`reindexdb`](https://www.postgresql.org/docs/13/app-reindexdb.html) rebuilds PostgreSQL database indexes.

1. Restart Supermarket:

    ```bash
    sudo supermarket-ctl restart
    ```

## Release-specific upgrade: Chef Infra Server 15.8.x

If you use Private Supermarket and upgrade to Chef Infra Server version 15.8.0 or above, refresh your logins and re-authenticate Supermarket with Chef Identity.

## Troubleshooting

### Recovering from database cleanup failures

If the `vacuumdb` or `reindexdb` commands fail, follow these steps:

1. Drop the Supermarket PostgreSQL database:

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "drop database supermarket"
    ```

1. Recreate the Supermarket PostgreSQL database:

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "create database supermarket"
    ```

1. Restore the Supermarket PostgreSQL database from the existing `supermarket-dump-archive.sql` dump file:

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump-archive.sql
    ```

1. Restart Supermarket:

    ```bash
    supermarket-ctl restart
    ```
