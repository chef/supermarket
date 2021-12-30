+++
title = "Upgrade Supermarket"
date = 2021-12-28T11:04:48-08:00
draft = true
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

Running Version| Upgrade Version | Supported Version
---------|----------|---------
 A1 | B1 | C1
 A2 | B2 | C2
 A3 | B3 | C3

## Upgrade Supermarket

### Database Preparation

### Upgrade Steps

## External PostgreSQL

The External PostgreSQL upgrade steps are provided as a courtesy. It is the responsibility of the user to upgrade and maintain any External PostgreSQL configurations.

Follow these steps to upgrade the PostgreSQL major version.

## Upgrade Supermarket

Do we need to upgrade Supermarket first?

### Backup PostgreSQL Database

1. Stop the Supermarket application

```bash
sudo supermarket-ctl stop
```

1. Start the Supermarket PostgreSQL service

```bash
sudo supermarket-ctl start postgresql
```

1. Back up the PostgreSQL database

```bash
/opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump.sql
```

1. Vacuum the PostgreSQL database:

```bash
/opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
```

1. Reindex the PostgreSQL database:

```bash
/opt/supermarket/embedded/bin/reindexdb --all -p 15432
```

1. Restart the Supermarket application

```bash
supermarket-ctl restart
```

### Recovering from Upgrade Failures

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
  /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump.sql
  ```

1. Restart the Supermarket application

```bash
supermarket-ctl restart
```
