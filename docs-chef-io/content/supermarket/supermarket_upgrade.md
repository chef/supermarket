+++
title = "Upgrade Supermarket"
date = 2021-12-28T11:04:48-08:00
draft = false
gh_repo = "supermarket"

[menu]
  [menu.supermarket]
    title = "Upgrades"
    identifier = "supermarket/server/upgrade.md"
    parent = "supermarket/server"
+++

<!-- markdownlint-disable MD033 -->
## Upgrade Matrix

  If running Supermarket 4.2, you can upgrade directly to the latest releases of Supermarket 5.0. If you are running a release with version less than 4.2 you must perform a stepped upgrade as outlined below.

Running Version | Upgrade Version | Supported Version
----------------|-----------------|------------------
4.2             | 5.0             | Yes
< 4.2           | 4.2             | No

## Supported Release

Chef Supermarket uses the PostgreSQL database. [PostgreSQL 9.3 is EOL](https://endoflife.date/postgresql) and Private Supermarket users should upgrade to [Supermarket 5.0](https://www.chef.io/downloads) or above and migrate to [PostgreSQL 13](https://www.postgresql.org/about/news/postgresql-13-released-2077/).

Chef Software supports Supermarket 5.0 release and later. Earlier releases are not supported. For more information about supported Chef Software see the [Supported Versions](https://docs.chef.io/versions/#supported-commercial-distributions) documentation.

## Upgrade a Private Supermarket

Every Private Supermarket installation is unique. These are general steps for upgrading a Private Supermarket.

  1. Stop the Supermarket services:

        ```bash
        sudo supermarket-ctl stop
        ```

  1. Backup the `/var/opt/supermarket` directory.
  1. Download the Chef Supermarket package from [Chef Downloads](https://www.chef.io/downloads).
  1. Upgrade your system by installing the new package using the appropriate package manager for your distribution:
     - For Ubuntu:

         ```bash
         dpkg -i /path/to/package/supermarket*.deb
         ```

     - For RHEL / CentOS:

         ```bash
         rpm -Uvh /path/to/package/supermarket*.rpm
         ```

  1. Reconfigure Chef Supermarket server:

      ```bash
      sudo supermarket-ctl reconfigure
      ```

  1. Once the Private Supermarket upgrade finishes, restart the services that run Chef Supermarket to clear the old installation of Chef Supermarket from the server memory.

      ```bash
      systemctl list-units | grep runsvdir
      ```

  1. Restart the unit:

      ```bash
      systemctl restart UNIT_NAME
      ```

      This will restart the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.

## Release Specific Upgrade: Supermarket 5.0 and PostgreSQL 13.4

Supermarket 5.0 upgrades PostgreSQL from 9.3 to 13.4. The 5.0 upgrade process requires a one-time downtime to vacuum, upgrade, and re-index the database.

### Supermarket 5.0 Changes

Prepare for the upgrade by following these steps:

1. Set the attribute: `default['supermarket']['postgresql']['pg_upgrade_timeout']` in `supermarket.rb` to the intended timeout value (***in seconds***) for the upgrade. Set this value based on the size of your data.
1. PostgreSQL 13 deprecated the `checkpoint-segments` attribute and we have removed it from the Supermarket configuration. Remove this entry from your configuration:

  ```ruby
  default['supermarket']['postgresql']['checkpoint_segments']
  ```

### PostgreSQL 13.4 Upgrade

Each Private Supermarket installation is unique. The PostgreSQL upgrade steps are a general process intended for the _internal PostgreSQL_.

- **External PostgreSQL**: The end user is responsible for upgrading and maintaining External PostgreSQL configurations.
- **Internal PostgreSQL**: The PostgreSQL upgrade steps are a general process intended for the _internal PostgreSQL_.

{{< danger >}}
**BACKUP THE SUPERMARKET DATABASE AND SECURE THE DATA.** Preserve your backup at all costs. Copy the backup to a second and separate location.
{{< /danger >}}

1. Backup the Supermarket database:

    Database migrations have inherent risk to your system. Create a backup before beginning any migration or update. This ensures that you have a recoverable state in case any step in the process fails. Copy the backup to a another disk that is not connected to the Private Supermarket installation. This ensures that you have state to restore, in case of a failure in the upgrade process

    Back up the PostgreSQL database before upgrading so you can restore the full database to a previous release in the event of a failure in the upgrade steps below.

    ```bash
    sudo -u supermarket /opt/supermarket/embedded/bin/pg_dumpall -U supermarket 1543 > /  tmp/supermarket-dump.sql
    ```

1. Vacuum the database:

    Run `VACUUM FULL` on the PostgreSQL database if you don't have automatic vacuuming set up. This process will reduce the size of the database by deleting unnecessary data and speeds up the migration. The `VACUUM FULL` operation takes around 1 to 2 minutes per gigabyte of data depending on the complexity of the data, and requires free disk space at least as large as the size of your database.

    For more information on upgrading using `vacuumdb` see the PostgreSQL 13   documentation for [vacuumdb](https://www.postgresql.org/docs/13/app-vacuumdb.html).

      ```bash
      sudo -u supermarket /opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
      ```

1. Upgrade Supermarket:

    Follow the [Upgrade a Private Supermarket]({{< relref "#upgrade-a-private-supermarket" >}}) steps.
<br></br>

1. Cleanup the installation:

    Follow these steps to clean up the old PostgreSQL installation and other clutter in the cache.

    1. Stop the Supermarket application:

        ```bash
        sudo supermarket-ctl stop
        ```

    1. Start the newly installed PostgreSQL server.

        ```bash
        sudo supermarket-ctl start postgresql
        ```

1. Reindex the database:

    `reindexdb` is a utility for rebuilding indexes in a PostgreSQL database.

    For more information on upgrading using `reindexdb` see the PostgreSQL 13   documentation for [reindexdb](https://www.postgresql.org/docs/13/app-reindexdb.html).

    ```bash
    sudo -u supermarket /opt/supermarket/embedded/bin/reindexdb --all -p 15432
    ```

1. Restart Supermarket:

    ```bash
    sudo supermarket-ctl restart
    ```

## Troubleshooting

### Recovering from Database Cleanup Failures

If either the `vacuumdb` or `reindexdb` commands fail

1. Drop the Supermarket PostgreSQL database

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "drop database supermarket"
    ```

1. Recreate the Supermarket PostgreSQL database

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "create database supermarket"
    ```

1. Restore Supermarket PostgreSQL database from the existing dump file: `supermarket-dump-archive.sql`

    ```bash
    /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump-archive.sql
    ```

1. Restart the Supermarket application

    ```bash
    supermarket-ctl restart
    ```
