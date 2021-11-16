### Follow these steps in case Postgres major version is being upgraded.

 - Stop currently running supermarket application
```
sudo supermarket-ctl stop
```
 - Start supermarket postgresql
```
sudo supermarket-ctl start postgresql
```

- Take backup of db:
```ruby
/opt/supermarket/embedded/bin/pg_dumpall -U supermarket -p 15432 > /tmp/supermarket-dump.sql
```

- Vacuum postgresDB:
```
/opt/supermarket/embedded/bin/vacuumdb --all --full -p 15432
```

- Reindex postgresDB:
```bash
/opt/supermarket/embedded/bin/reindexdb --all -p 15432
```

- Restore DB if either **vacuumdb** or **reindexdb** fails

   - Drop the supermarket database
  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "drop database supermarket"
  ```
   - Recreate the supermarket database
  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d postgres -p 15432 -c "create database supermarket"
  ```
   - Restore supermarket database from existing dump.sql file

  ```bash
  /opt/supermarket/embedded/bin/psql -U supermarket -d supermarket -p 15432 -f /tmp/supermarket-dump.sql
  ```

- Restart supermarket application
```bash
supermarket-ctl restart
```