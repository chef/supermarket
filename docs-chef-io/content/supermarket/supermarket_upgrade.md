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

This document describes how to upgrade Supermarket.

## Supported versions

Progress Chef supports Supermarket 5.0 and later. For more information about supported Chef Software see the [supported versions documentation](/versions/#supported-free-distributions).

### PostgreSQL bundled with Supermarket

Supermarket is bundled with PostgreSQL.
The following table shows which version of PostgreSQL is bundled with Supermarket.

| Supermarket version | PostgreSQL version |
|---------------------|--------------------|
| >= 4.2 and < 5.0    | 9.3                |
| >= 5.0 and < 5.2    | 13.4               |
| >= 5.2              | 13.18              |

## Before you upgrade

Use these guidelines to determine which upgrade process you should follow:

- If you're upgrading from Supermarket 4.2.x to Supermarket 5.x, this also upgrades the version PostgreSQL that's embedded with Supermarket and involves extra steps for managing the database and Supermarket configuration. For this process, follow the [Upgrade to Supermarket 5.0 documentation](#upgrade-to-supermarket-50).

- If you want to upgrade from a version of Supermarket that's less than 4.2 to Supermarket 5.x, first upgrade to Supermarket 4.2.x using the [regular upgrade process](#upgrade-supermarket), then [upgrade to version 5.x](#upgrade-to-supermarket-50).

- For any other upgrade, follow the [regular upgrade process](#upgrade-supermarket).

## Upgrade Supermarket

To upgrade Supermarket, follow these steps:

1. Stop the Supermarket services:

    ```bash
    sudo supermarket-ctl stop
    ```

1. Backup the `/var/opt/supermarket` directory.
1. Download a Supermarket package from [Chef Downloads](https://www.chef.io/downloads).
1. Upgrade your system by installing the new package using the appropriate package manager for your distribution:

    - For Ubuntu:

      ```bash
      dpkg -i /path/to/package/supermarket*.deb
      ```

    - For RHEL:

      ```bash
      rpm -Uvh /path/to/package/supermarket*.rpm
      ```

1. Get the installed PostgreSQL version that's bundled with Supermarket:

    ```bash
    sudo /opt/supermarket/embedded/bin/postgres --version
    ```

1. Start the Chef Supermarket services:

    ```bash
    sudo supermarket-ctl start
    ```

1. Reconfigure Chef Supermarket server:

    ```bash
    sudo supermarket-ctl reconfigure
    ```

1. Once the private Supermarket upgrade finishes, restart the services that run Chef Supermarket to clear the old installation of Chef Supermarket from the server memory.

    ```bash
    systemctl list-units | grep runsvdir
    ```

1. Restart the unit:

    ```bash
    systemctl restart <UNIT_NAME>
    ```

    This will restart the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.

## Upgrade to Supermarket 5.0

Upgrading from Supermarket 4.2.x to 5.0 upgrades PostgreSQL from 9.3 to 13.4.
This upgrade process requires a one-time downtime to vacuum, upgrade, and re-index the database.

If you're upgrading from a version of Supermarket before 4.2, upgrade to version 4.2.x using the regular upgrade instructions, then upgrade version 5.x.

### Configure PostgreSQL in the Supermarket settings

Prepare for the upgrade by following these steps:

1. In the `supermarket.rb` settings, set the attribute `pg_upgrade_timeout` to the intended timeout value in seconds for the upgrade.

    For example:

    ```rb
    default['supermarket']['postgresql']['pg_upgrade_timeout'] = <SECONDS>
    ```

    Set this value based on the size of your data.

1. Remove the `checkpoint-segments` attribute from your `supermarket.rb` settings:

    ```ruby
    # This setting is EOL in Supermarket 5.x and PostgreSQL 9.4
    # default['supermarket']['postgresql']['checkpoint_segments']
    ```

   PostgreSQL removed the `checkpoint_segments` attribute and we removed it from the Supermarket configuration.

### Prepare PostgreSQL embedded with Supermarket

Prepare the PostgreSQL database for upgrading:

1. Backup the Supermarket database:

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

    This reduces the size of the database by deleting unnecessary data and speeds up the migration.
    This takes around 1 to 2 minutes per gigabyte of data depending on the complexity of the data, and requires free disk space at least as large as the size of your database.

    For more information, see the [`vacuumdb` documentation](https://www.postgresql.org/docs/13/app-vacuumdb.html).

### Upgrade Supermarket

To upgrade Supermarket, follow these steps:

1. Stop the Supermarket services:

    ```bash
    sudo supermarket-ctl stop
    ```

1. Backup the `/var/opt/supermarket` directory.

1. Download a Supermarket package from [Chef Downloads](https://www.chef.io/downloads).

1. Upgrade your system by installing the new package using the appropriate package manager for your distribution:

    - For Ubuntu:

      ```bash
      dpkg -i /path/to/package/supermarket*.deb
      ```

    - For RHEL:

      ```bash
      rpm -Uvh /path/to/package/supermarket*.rpm
      ```

1. Get the installed PostgreSQL version that's bundled with Supermarket:

    ```bash
    sudo /opt/supermarket/embedded/bin/postgres --version
    ```

1. Reconfigure Chef Supermarket server:

    ```bash
    sudo supermarket-ctl reconfigure
    ```

1. Once the private Supermarket upgrade finishes, restart the services that run Chef Supermarket to clear the old installation of Chef Supermarket from the server memory.

    ```bash
    systemctl list-units | grep runsvdir
    ```

1. Restart the unit:

    ```bash
    systemctl restart <UNIT_NAME>
    ```

    This restarts the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.

### Cleanup the PostgreSQL database

Follow these steps to clean up the old PostgreSQL installation and other clutter in the cache:

1. Stop Supermarket:

    ```bash
    sudo supermarket-ctl stop
    ```

1. Start the newly installed PostgreSQL server.

    ```bash
    sudo supermarket-ctl start postgresql
    ```

1. Reindex the PostgreSQL database:

    ```bash
    sudo -u supermarket /opt/supermarket/embedded/bin/reindexdb --all -p 15432
    ```

    [`reindexdb`](https://www.postgresql.org/docs/13/app-reindexdb.html) is a utility for rebuilding PostgreSQL database indexes.

1. Restart Supermarket:

    ```bash
    sudo supermarket-ctl restart
    ```

## Release Specific Upgrade: Chef Infra Server 15.8.x

Private Supermarket users upgrading to Chef Infra Server version 15.8.0 or above must refresh their logins and re-authenticate Supermarket with Chef Identity.

## Troubleshooting

### Recovering from database cleanup failures

If either the `vacuumdb` or `reindexdb` commands fail, follow these steps:

1. Drop the Supermarket PostgreSQL database:

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "drop database supermarket"
    ```

1. Recreate the Supermarket PostgreSQL database:

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "create database supermarket"
    ```

1. Restore Supermarket PostgreSQL database from the existing `supermarket-dump-archive.sql` dump file:

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump-archive.sql
    ```

1. Restart Supermarket:

    ```bash
    supermarket-ctl restart
    ```
