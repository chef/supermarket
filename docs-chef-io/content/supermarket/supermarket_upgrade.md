+++
title = "Upgrade Supermarket"
date = 2021-12-28T11:04:48-08:00
draft = false
gh_repo = "supermarket"
publishDate = 2022-01-03

[menu]
  [menu.supermarket]
    title = "Upgrades"
    identifier = "supermarket/server/upgrade.md"
    parent = "supermarket/server"
    weight = 25
+++

Chef Supermarket uses the PostgreSQL database. [PostgreSQL 9.6 is EOL](https://endoflife.date/postgresql) and Private Supermarket users should upgrade to [Supermarket 4.x](https://www.chef.io/downloads/tools/supermarket) and migrate to [Postgres 13](https://www.postgresql.org/about/news/postgresql-13-released-2077/).

## Upgrade a Private Supermarket

1. Shut down the server running Private Supermarket.
1. Backup the `/var/opt/supermarket` directory.
1. Download the [Chef Supermarket](https://www.chef.io/downloads/tools/supermarket) package.
1. Upgrade your system with the new package using the appropriate package manager for your distribution:

    - For Ubuntu:

        ```bash
        dpkg -i /path/to/package/supermarket*.deb
        ```

    - For RHEL / CentOS:

        ```bash
        rpm -Uvh /path/to/package/supermarket*.rpm
        ```

1. [Reconfigure](/ctl_supermarket/#reconfigure) the server that Chef Supermarket is installed on:

    ```bash
    sudo supermarket-ctl reconfigure
    ```

Private Supermarket is updated on your server now. We recommend restarting the services that run Chef Supermarket to ensure that the old installation of Chef Supermarket doesn't persist in the server memory.

1. Get the name of the active unit:

    ```bash
    systemctl list-units | grep runsvdir
    ```

1. Restart the unit:

    ```bash
    systemctl restart UNIT_NAME
    ```

    This will restart the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.


## Migrate to PostgreSQL 13

TODO: What package SEMVER has the PostgreSQL update

PostgreSQL 13.3 is installed with the Supermarket 4.X.X upgrade package.

The External PostgreSQL upgrade steps are provided as a courtesy. It is the responsibility of the user to upgrade and maintain any External PostgreSQL configurations.

Follow these steps to upgrade the PostgreSQL major version.

### Run PostgreSQL

1. Stop the Supermarket application

```bash
sudo supermarket-ctl stop
```

1. Start the Supermarket PostgreSQL service

```bash
sudo supermarket-ctl start postgresql
```

### Create an Archive Backup

Database migrations carry inherent risk. A best practice to mitigate risk is to create an archival copy and save it to a secondary location before proceeding with any actions that touch the data. The archival copy is your failsafe for restoring the database. Do not use it as a working copy.

1. Back up the Database

`pg_dumpall` is a utility for writing out ("dumping") all PostgreSQL databases of a cluster into one script file. The script file contains SQL commands that can be used as input to psql to restore the databases.

For more information on upgrading using `pg_dumpall` see the PostgreSQL 13 documentation, section [18.6.1 Upgrading Data via pg_dumpall](https://www.postgresql.org/docs/13/upgrading.html).

```bash
/opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump-archive.sql
```

1. Copy the backup to a separate disk, one that is not connected to the Supermarket.

### Prepare the Database

#### Option 1: Vacuum the PostgreSQL database

`vacuumdb --all --full` rewrites the entire contents of all tables into a disk files with no extra space, and returns unused space to the operating system.

For more information on upgrading using `vacuumdb` see the PostgreSQL 13 documentation for [vacuumdb](https://www.postgresql.org/docs/13/app-vacuumdb.html).

```bash
/opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
```

#### Option 2: Vacuum and Analyze the PostgreSQL database

`vacuumdb --all --full --analyze` rewrites the entire contents of all tables into a disk files with no extra space, returns unused space to the operating system, and collects statistics about the database. It stores the results in the `pg_statistic` system catalog, which is useful for planning efficient queries.

```bash
/opt/supermarket/embedded/bin/vacuumdb --all --full --analyze -p 15432
```

### Backup the Cleaned Database (optional)

This is an optional step for the sufficiently paranoid. Estimate the time needed for a second (the 'working') backup based as the same amount of time used in the first backup. The working backup provides a closer restore point than the archival copy if the next step of reindexing fails.

```bash
/opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump-working.sql
```

### Reindex the Database

`reindexdb` is a utility for rebuilding indexes in a PostgreSQL database.

For more information on upgrading using `reindexdb` see the PostgreSQL 13 documentation for [vacuumdb](https://www.postgresql.org/docs/13/app-reindexdb.html).

1. Reindex the PostgreSQL database:

```bash
/opt/supermarket/embedded/bin/reindexdb --all -p 15432
```

### Restart Supermarket

1. Restart the Supermarket application

```bash
supermarket-ctl restart
```

## Recovering from Upgrade Failures

If either the `vacuumdb` or `reindexdb` commands fail

1. Drop the Supermarket PostgreSQL database

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "drop database supermarket"
  ```

1. Recreate the Supermarket PostgreSQL database

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "create database supermarket"
  ```

1. Restore Supermarket PostgreSQL database from the existing `dump.sql` file

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump-archive.sql
  ```

1. Restart the Supermarket application

```bash
supermarket-ctl restart
```

1. Review the [PostgreSQL error logs](https://www.postgresql.org/docs/13/runtime-config-logging.html). Once you understand and resolve the failure, then repeat the upgrade steps.
