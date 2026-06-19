# upgrade-postgres.sh

Upgrades the PostgreSQL instance used by a Chef Supermarket deployment from any older version to the latest (default: 17).

Reads all connection details from `/etc/supermarket/supermarket.rb` automatically — no manual configuration needed.

---

## Prerequisites

- Must be run as **root** (or `sudo`)
- `supermarket-ctl` must be installed and in PATH
- `PGPASSWORD` environment variable must be set if your database requires password authentication (not needed for embedded deployments using peer auth)

---

## Quick Start

### Dry run (no changes made)
```bash
sudo ./upgrade-postgres.sh --dry-run
```
Prints every command that _would_ run. Safe to execute at any time.

### Live upgrade
```bash
sudo ./upgrade-postgres.sh
```
You will be prompted to type `yes` to confirm before anything is changed.

---

## Command-Line Options

| Option | Default | Description |
|---|---|---|
| `--config PATH` | `/etc/supermarket/supermarket.rb` | Path to the Supermarket config file |
| `--target-version VER` | `17` | PostgreSQL major version to upgrade to |
| `--backup-dir PATH` | `/var/opt/supermarket/backups` | Where to write the pg_dump backup file |
| `--docker-image IMAGE` | `postgres:17` | Docker image to use when replacing a container |
| `--docker-container NAME` | `supermarket_postgres` | Name of the existing Docker container to replace |
| `--docker-compose-file PATH` | _(none)_ | Path to `docker-compose.yml` — if provided, uses `docker compose` instead of plain `docker run` |
| `--skip-restore` | _(off)_ | Take the backup and stop — skip the upgrade and restore steps. Useful for taking a pre-upgrade snapshot |
| `--dry-run` | _(off)_ | Print all commands without executing any of them |
| `--help` | | Show usage information |

---

## What the Script Does

1. **Parses** `supermarket.rb` to read DB host, port, user, database name, and data directory
2. **Stops** all Supermarket services via `supermarket-ctl stop`
3. **Backs up** the database with `pg_dump` (custom format, compressed) to a timestamped file
4. **Upgrades** PostgreSQL using the appropriate strategy for your deployment:
   - **Embedded** — calls `supermarket-ctl pg-upgrade --version <VER>` (in-place `pg_upgrade`)
   - **Docker** — pulls the new image and recreates the container (data volumes are preserved)
   - **External package** — prints guided `apt`/`yum` instructions and waits for you to complete them
5. **Re-enables** `plpgsql` and `pg_trgm` extensions on the upgraded instance
6. **Restores** data from the dump (Docker and external modes only; embedded uses in-place migration)
7. **Reconfigures** and restarts Supermarket via `supermarket-ctl reconfigure && start`
8. **Smoke tests** the result — prints the running PG version and cookbook count

The backup file is **always retained** after the upgrade completes.

---

## Developer Testing

When testing against a non-production deployment, use `--dry-run` first to verify the detected configuration is correct, then run the live upgrade:

```bash
# 1. Confirm the script reads your config correctly
sudo ./upgrade-postgres.sh --dry-run

# 2. Override defaults if your test environment differs
sudo ./upgrade-postgres.sh \
  --config /etc/supermarket/supermarket.rb \
  --target-version 17 \
  --backup-dir /tmp/pg-test-backups \
  --dry-run

# 3. Take a backup snapshot without upgrading (safe pre-flight)
sudo ./upgrade-postgres.sh --skip-restore

# 4. Run the full upgrade
sudo ./upgrade-postgres.sh --target-version 17
```

For a **Docker** test environment with a custom compose file:

```bash
sudo ./upgrade-postgres.sh \
  --docker-compose-file /opt/supermarket/docker-compose.yml \
  --docker-container supermarket_postgres \
  --target-version 17 \
  --dry-run
```

---

## Customer Upgrade (Production)

### Step 1 — Dry run (verify before touching anything)
```bash
sudo ./upgrade-postgres.sh --dry-run
```
Review the output. Confirm the detected host, port, database name, and deployment mode are correct.

### Step 2 — Take a backup snapshot (optional but recommended)
```bash
sudo ./upgrade-postgres.sh --skip-restore
```
This stops Supermarket, writes a timestamped dump, and restarts the service. No upgrade is performed.

### Step 3 — Run the upgrade
```bash
sudo ./upgrade-postgres.sh
```
Type `yes` at the confirmation prompt. The script will stop Supermarket, dump the database, upgrade PostgreSQL, restore data, reconfigure, and restart the service.

> **Note for external-password databases:** set `PGPASSWORD` before running:
> ```bash
> export PGPASSWORD='your-db-password'
> sudo -E ./upgrade-postgres.sh
> ```

---

## Backup Location

Backups are written to `/var/opt/supermarket/backups/` by default, named:

```
supermarket_pg_dump_YYYYMMDD_HHMMSS.dump
```

To restore manually from a backup:
```bash
pg_restore \
  --host=<host> --port=<port> \
  --username=<user> --dbname=supermarket \
  --clean --if-exists --verbose \
  /var/opt/supermarket/backups/supermarket_pg_dump_<timestamp>.dump
```
