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

## Upgrade Matrix
  If running Supermarket 4.2, you can upgrade directly to the latest releases of Supermarket 4.3. If you are running a release with version less than 4.2 you must perform a stepped upgrade as outlined below.
  Running Version| Upgrade Version | Supported Version
  ---------|----------|---------
  4.2 | 4.3 | No
  4.1 | 4.2 | No
  4.0 | 4.2 | No
  < 4.0 | 4.2 | No

## Supported Release
  Chef Supermarket uses the PostgreSQL database. [PostgreSQL 9.3 is EOL](https://endoflife.date/postgresql) and Private Supermarket users should upgrade to [Supermarket 4.3](https://www.chef.io/downloads/tools/supermarket) or above and migrate to [Postgres 13](https://www.postgresql.org/about/news/postgresql-13-released-2077/).

  Supermarket 4.3 and later are supported Chef Software releases. Earlier releases are not supported. For more information about supported Chef Software see the [Supported Versions](https://docs.chef.io/versions/#supported-commercial-distributions) documentation.

## General Steps to Upgrade a Private Supermarket
  1. Shut down the server running Private Supermarket.
  1. Backup the `/var/opt/supermarket` directory.
  1. Download the [Chef Supermarket](https://www.chef.io/downloads/tools/supermarket) package.
  1. Upgrade your system by installing the new package using the appropriate package manager for your distribution:
     - For Ubuntu:
         
         ```bash
         dpkg -i /path/to/package/supermarket*.deb
         ```
     - For RHEL / CentOS:
         
         ```bash
         rpm -Uvh /path/to/package/supermarket*.rpm
         ```
  1. Reconfigure the server that Chef Supermarket is installed on:
      ```bash
      sudo supermarket-ctl reconfigure
      ```
  1. Private Supermarket is updated on your server now. We recommend restarting the services that run Chef Supermarket to ensure that the old installation of Chef Supermarket doesn't persist in the server memory.
      ```bash
      systemctl list-units | grep runsvdir
      ```
  1. Restart the unit:

      ```bash
      systemctl restart UNIT_NAME
      ```
      This will restart the `runsvdir`, `runsv`, and `svlogd` service processes that run Chef Supermarket.
## Release Specific Steps
---
## Upgrading to Supermarket Version: 4.3
  Supermarket 4.3 upgrades PostgreSQL from 9.3 to 13.4. The 4.3 upgrade process requires a one-time downtime to vacuum, upgrade, and re-index the database.

  ---
  > NOTE: Set the default['supermarket']['postgresql']['pg_upgrade_timeout'] attribute in supermarket.rb to the intended timeout value for the upgrade. Set this value based on the size of your data.
  ---

## Pre Upgrade Database Preparation
  1. Run `VACUUM FULL` on the PostgreSQL database if you don’t have automatic vacuuming set up. This process will reduce the size of the database by deleting unnecessary data and speeds up the migration. The `VACUUM FULL` operation takes around 1 to 2 minutes per gigabyte of data depending on the complexity of the data, and requires free disk space at least as large as the size of your database.
      ```
      sudo -u supermarket /opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
      ```
  1. Back up the PostgreSQL database before upgrading so you can restore the full database to a previous release in the event of a failure in the upgrade steps below.
      ```bash
      sudo -u supermarket /opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump.sql
      ```

## Upgrade Steps

### Scenario-1: External PostgreSQL
  The External PostgreSQL upgrade steps are provided as a courtesy. It is the responsibility of the user to upgrade and maintain any External PostgreSQL configurations.

### Scenario-2: Internal PostgreSQL
  Follow the steps below in case you are using an internal postgreSQL for your private supermarket.
  1. Download the Package for Supermarket 4.3 as specified in the [general installation guidelines](#general-steps-to-upgrade-a-private-supermarket).
  1. Install the downloaded package using the relevant package installer as specified in the [general installation guidelines](#general-steps-to-upgrade-a-private-supermarket).
  1. Reconfigure supermarket as specified in the [general installation guidelines](#general-steps-to-upgrade-a-private-supermarket). Once reconfigure is complete you should have all your data migrated from postgres 9.3 to 13.4
  1. Now you need to follow the steps below to cleanup the data in the database to remove the unnecessary clutter.
  1. Stop the Supermarket application
      ```bash
      sudo supermarket-ctl stop
      ```
  1. Start the Supermarket PostgreSQL service. This starts the newly-installed PostgreSQL 13 server.
      ```bash
      sudo supermarket-ctl start postgresql
      ```
  1. Create an Archive Backup
      
      Database migrations carry inherent risk. A best practice to mitigate risk is to create an archival copy and save it to a secondary location before proceeding with any actions that touch the data. The archival copy is your failsafe for restoring the database. Do not use it as a working copy.

      1. Back up the database

          `pg_dumpall` is a utility for writing out ("dumping") all PostgreSQL databases of a cluster into one script file. The script file contains SQL commands that can be used as input to psql to restore the databases.

          For more information on upgrading using `pg_dumpall` see the PostgreSQL 13 documentation, section [18.6.1 Upgrading Data via pg_dumpall](https://www.postgresql.org/docs/13/upgrading.html).
              
            ```bash
            sudo -u supermarket /opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump-archive.sql
            ```
     1. Copy the backup to a separate disk, one that is not connected to the Supermarket.
### Vacuum the Database
#### **Option 1**: Vacuum the PostgreSQL database
  `vacuumdb --all --full` rewrites the entire contents of all tables into a disk files with no extra space, and returns unused space to the operating system.

  Vacuum the database:

  ```bash
  /opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
  ```

  For more information on upgrading using `vacuumdb` see the PostgreSQL 13 documentation for [vacuumdb](https://www.postgresql.org/docs/13/app-vacuumdb.html).
#### **Option 2**: Vacuum and Analyze the PostgreSQL database
  `vacuumdb --all --full --analyze` rewrites the entire contents of all tables into a disk files with no extra space, returns unused space to the operating system, and collects statistics about the database. It stores the results in the `pg_statistic` system catalog, which is useful for planning efficient queries. This command takes considerably more time to run.

  Vacuume and analyze the database:

  ```bash
  /opt/supermarket/embedded/bin/vacuumdb --all --full --analyze -p 15432
  ```
### Backup the Cleaned Database (optional)

  This is an optional step for the sufficiently paranoid. Estimate the time needed for a second (the 'working') backup based as the same amount of time used in the first backup. The working backup provides a closer restore point than the archival copy if the next step of reindexing fails.

  Create a 'working' copy of the cleaned database:

  ```bash
  sudo -u supermarket /opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump-working.sql
  ```
### Reindex the PostgreSQL database:
  `reindexdb` is a utility for rebuilding indexes in a PostgreSQL database.

  Reindex the PostgreSQL database:
  ```bash
  sudo -u supermarket /opt/supermarket/embedded/bin/reindexdb --all -p 15432
  ```
  
  For more information on upgrading using `reindexdb` see the PostgreSQL 13 documentation for [reindexdb](https://www.postgresql.org/docs/13/app-reindexdb.html).
### Restart Supermarket

```bash
sudo supermarket-ctl restart
```

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
