+++
title = "Upgrade Supermarket"

date = 2021-12-28T11:04:48-08:00
draft = false
publishDate = 2022-01-03

[menu]
  [menu.supermarket]
    title = "Upgrades"
    identifier = "supermarket/server/upgrade.md"
    parent = "supermarket/server"
    weight = 25
+++

## External PostgreSQL

Follow these steps to upgrade to a major version of PostgreSQL.

### Backup PostgreSQL Database

- Stop Supermarket application

```bash
sudo supermarket-ctl stop
```

- Start Supermarket PostgreSQL

```bash
sudo supermarket-ctl start postgresql
```

- Back up the PostgreSQL database

```bash
/opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump.sql
```

- Vacuum the PostgreSQL database:

```bash
/opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
```

- Reindex the PostgreSQL database:

```bash
/opt/supermarket/embedded/bin/reindexdb --all -p 15432
```

- If either the `vacuumdb` or `reindexdb` commands fail

  - Drop the supermarket database

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "drop database supermarket"
  ```

  - Recreate the supermarket database

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "create database supermarket"
  ```

  - Restore supermarket database from existing `dump.sql` file

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump.sql
  ```

- Restart supermarket application

```bash
supermarket-ctl restart
```
