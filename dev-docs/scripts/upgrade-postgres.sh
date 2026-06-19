#!/usr/bin/env bash
# =============================================================================
# upgrade-postgres.sh
#
# Upgrades the PostgreSQL instance used by a Chef Supermarket deployment.
#
# Reads connection details from /etc/supermarket/supermarket.rb (or a path
# you supply via --config).  Handles two deployment modes:
#
#   EMBEDDED  – Supermarket's own bundled PostgreSQL managed by supermarket-ctl
#               (default['supermarket']['postgresql']['enable'] = true)
#
#   EXTERNAL  – A standalone PostgreSQL server or Docker container
#               (default['supermarket']['postgresql']['enable'] = false)
#
# Steps performed:
#   1. Parse configuration from supermarket.rb
#   2. Stop Supermarket services
#   3. Dump the database with pg_dump
#   4. Upgrade PostgreSQL (embedded: pg_upgrade via supermarket-ctl;
#                          docker:    pull new image + recreate container;
#                          package:   apt/yum upgrade)
#   5. Re-enable extensions and reload Rails schema
#   6. Restore data from dump
#   7. Reconfigure and restart Supermarket
#
# Usage:
#   sudo ./upgrade-postgres.sh [OPTIONS]
#
# Options:
#   --config PATH          Path to supermarket.rb  (default: /etc/supermarket/supermarket.rb)
#   --target-version VER   Target PostgreSQL major version, e.g. 17  (default: 17)
#   --backup-dir PATH      Directory to write the pg_dump file        (default: /var/opt/supermarket/backups)
#   --docker-image IMAGE   Docker image to use when in container mode (default: postgres:17)
#   --docker-container NAME  Docker container name to upgrade         (default: supermarket_postgres)
#   --docker-compose-file PATH  Path to docker-compose.yml if used   (optional)
#   --skip-restore         Dump and upgrade only; do not restore data (useful for testing)
#   --dry-run              Print what would be done without executing
#   --help                 Show this help text
#
# Requirements:
#   - Must run as root (or with sudo)
#   - ruby must be in PATH to parse supermarket.rb (uses the embedded ruby from
#     /opt/supermarket/embedded/bin/ruby if available)
#   - pg_dump / pg_restore must be available (embedded or system)
# =============================================================================

set -euo pipefail

# ── Defaults ─────────────────────────────────────────────────────────────────
SUPERMARKET_CONFIG="/etc/supermarket/supermarket.rb"
TARGET_PG_VERSION="17"
BACKUP_DIR="/var/opt/supermarket/backups"
DOCKER_IMAGE="postgres:${TARGET_PG_VERSION}"
DOCKER_CONTAINER="supermarket_postgres"
DOCKER_COMPOSE_FILE=""
SKIP_RESTORE=false
DRY_RUN=false

SUPERMARKET_CTL="/usr/bin/supermarket-ctl"
EMBEDDED_RUBY="/opt/supermarket/embedded/bin/ruby"
EMBEDDED_PSQL="/opt/supermarket/embedded/bin/psql"
EMBEDDED_PGDUMP="/opt/supermarket/embedded/bin/pg_dump"
EMBEDDED_PGRESTORE="/opt/supermarket/embedded/bin/pg_restore"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
DUMP_FILE=""

# ── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
die()     { error "$*"; exit 1; }
run()     { if $DRY_RUN; then echo -e "${YELLOW}[DRY-RUN]${NC} $*"; else eval "$*"; fi; }

# ── Argument parsing ──────────────────────────────────────────────────────────
usage() {
  grep '^#' "$0" | grep -v '#!/' | sed 's/^# \{0,2\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)              SUPERMARKET_CONFIG="$2";   shift 2 ;;
    --target-version)      TARGET_PG_VERSION="$2";    DOCKER_IMAGE="postgres:${TARGET_PG_VERSION}"; shift 2 ;;
    --backup-dir)          BACKUP_DIR="$2";            shift 2 ;;
    --docker-image)        DOCKER_IMAGE="$2";          shift 2 ;;
    --docker-container)    DOCKER_CONTAINER="$2";      shift 2 ;;
    --docker-compose-file) DOCKER_COMPOSE_FILE="$2";   shift 2 ;;
    --skip-restore)        SKIP_RESTORE=true;          shift ;;
    --dry-run)             DRY_RUN=true;               shift ;;
    --help|-h)             usage ;;
    *) die "Unknown option: $1  (use --help for usage)" ;;
  esac
done

DUMP_FILE="${BACKUP_DIR}/supermarket_pg_dump_${TIMESTAMP}.dump"

# ── Preflight checks ──────────────────────────────────────────────────────────
preflight() {
  [[ $EUID -eq 0 ]] || die "This script must be run as root (sudo)."
  [[ -f "$SUPERMARKET_CONFIG" ]] || die "supermarket.rb not found at: $SUPERMARKET_CONFIG"
  info "Preflight checks passed."
}

# ── Parse supermarket.rb ──────────────────────────────────────────────────────
# Uses Ruby to evaluate the relevant attribute assignments rather than fragile
# grep/sed — handles multi-line and variable-interpolated values correctly.
parse_config() {
  info "Parsing configuration from $SUPERMARKET_CONFIG ..."

  # Resolve ruby binary
  RUBY_BIN="ruby"
  [[ -x "$EMBEDDED_RUBY" ]] && RUBY_BIN="$EMBEDDED_RUBY"

  local parse_script
  parse_script=$(cat <<'RUBY'
config_file = ARGV[0]

# Stub the Chef node/attribute DSL just enough to evaluate the file
node = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

# Seed the values that default.rb derives from node attributes so they
# resolve correctly even without a full Chef run.
node['supermarket']['postgresql']['version']        = '13'
node['supermarket']['postgresql']['port']           = 15432
node['supermarket']['postgresql']['username']       = 'supermarket'
node['supermarket']['postgresql']['listen_address'] = '127.0.0.1'
node['supermarket']['postgresql']['enable']         = true
node['supermarket']['postgresql']['external']       = false
node['supermarket']['database']['name']             = 'supermarket'
node['supermarket']['database']['host']             = node['supermarket']['postgresql']['listen_address']
node['supermarket']['database']['port']             = node['supermarket']['postgresql']['port']
node['supermarket']['database']['user']             = node['supermarket']['postgresql']['username']
node['supermarket']['postgresql']['data_directory'] = "/var/opt/supermarket/postgresql/13/data"

# Provide a default() method shim on Hash for DSL compatibility
class Hash
  def default_value(key, val)
    dig_keys = key.is_a?(Array) ? key : [key]
    dig_keys.reduce(self) { |h,k| h[k] }
  end
end

def default; end  # no-op for bare `default` calls in the file

# Evaluate the config file inside a binding that has `node` and `default`
eval_binding = binding
eval(File.read(config_file), eval_binding, config_file)

pg  = node['supermarket']['postgresql']
db  = node['supermarket']['database']

puts "PG_ENABLE=#{pg['enable']}"
puts "PG_EXTERNAL=#{pg['external']}"
puts "PG_VERSION=#{pg['version']}"
puts "PG_HOST=#{db['host'] || pg['listen_address']}"
puts "PG_PORT=#{db['port'] || pg['port']}"
puts "PG_USER=#{db['user'] || pg['username']}"
puts "PG_DATABASE=#{db['name']}"
puts "PG_DATA_DIR=#{pg['data_directory']}"
RUBY
)

  local parsed
  parsed=$("$RUBY_BIN" -e "$parse_script" "$SUPERMARKET_CONFIG" 2>/dev/null) \
    || die "Failed to parse $SUPERMARKET_CONFIG — check Ruby syntax in the config file."

  while IFS='=' read -r key value; do
    case "$key" in
      PG_ENABLE)    PG_ENABLE="$value"   ;;
      PG_EXTERNAL)  PG_EXTERNAL="$value" ;;
      PG_VERSION)   PG_VERSION="$value"  ;;
      PG_HOST)      PG_HOST="$value"     ;;
      PG_PORT)      PG_PORT="$value"     ;;
      PG_USER)      PG_USER="$value"     ;;
      PG_DATABASE)  PG_DATABASE="$value" ;;
      PG_DATA_DIR)  PG_DATA_DIR="$value" ;;
    esac
  done <<< "$parsed"

  # Determine deployment mode
  if [[ "$PG_ENABLE" == "false" || "$PG_EXTERNAL" == "true" ]]; then
    # External DB — detect if it's Docker or a package install
    if docker inspect "$DOCKER_CONTAINER" &>/dev/null 2>&1; then
      PG_MODE="docker"
    else
      PG_MODE="external_package"
    fi
  else
    PG_MODE="embedded"
  fi

  info "Deployment mode : $PG_MODE"
  info "PostgreSQL host : $PG_HOST:$PG_PORT"
  info "Database        : $PG_DATABASE"
  info "DB user         : $PG_USER"
  info "Current version : $PG_VERSION"
  info "Target version  : $TARGET_PG_VERSION"
  [[ "$PG_MODE" == "embedded" ]] && info "Data directory  : $PG_DATA_DIR"
}

# ── Resolve pg_dump / psql binaries ──────────────────────────────────────────
resolve_pg_binaries() {
  if [[ -x "$EMBEDDED_PGDUMP" ]]; then
    PGDUMP="$EMBEDDED_PGDUMP"
    PGRESTORE="$EMBEDDED_PGRESTORE"
    PSQL="$EMBEDDED_PSQL"
  else
    PGDUMP=$(command -v pg_dump    || die "pg_dump not found — install postgresql-client.")
    PGRESTORE=$(command -v pg_restore || die "pg_restore not found.")
    PSQL=$(command -v psql         || die "psql not found.")
  fi
  info "Using pg_dump: $PGDUMP"
}

# ── Step 1: Stop Supermarket ──────────────────────────────────────────────────
stop_supermarket() {
  info "=== Step 1: Stopping Supermarket services ==="
  if [[ -x "$SUPERMARKET_CTL" ]]; then
    run "$SUPERMARKET_CTL stop"
    # Give runit a moment to fully stop supervised services
    $DRY_RUN || sleep 5
  else
    warn "supermarket-ctl not found at $SUPERMARKET_CTL — skipping service stop."
    warn "If Supermarket is running, stop it manually before this script writes data."
  fi
}

# ── Step 2: Backup ────────────────────────────────────────────────────────────
backup_database() {
  info "=== Step 2: Backing up database ==="
  run "mkdir -p '$BACKUP_DIR'"
  run "chmod 700 '$BACKUP_DIR'"

  local pg_dump_cmd="$PGDUMP \
    --host='$PG_HOST' \
    --port='$PG_PORT' \
    --username='$PG_USER' \
    --format=custom \
    --compress=9 \
    --no-password \
    --verbose \
    --file='$DUMP_FILE' \
    '$PG_DATABASE'"

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} $pg_dump_cmd"
  else
    # pg_dump authenticates via peer auth (embedded) or PGPASSWORD env var.
    # For external DBs set PGPASSWORD before calling this script, e.g.:
    #   export PGPASSWORD=secret; sudo -E ./upgrade-postgres.sh
    PGPASSWORD="${PGPASSWORD:-}" eval "$pg_dump_cmd" \
      || die "pg_dump failed — backup not created. Aborting upgrade."
    info "Backup written to: $DUMP_FILE"
    ls -lh "$DUMP_FILE"
  fi
}

# ── Step 3a: Upgrade embedded PostgreSQL ─────────────────────────────────────
upgrade_embedded() {
  info "=== Step 3: Upgrading embedded PostgreSQL via supermarket-ctl ==="

  if [[ ! -x "$SUPERMARKET_CTL" ]]; then
    die "supermarket-ctl not found — cannot perform embedded upgrade."
  fi

  # supermarket-ctl provides a pg-upgrade sub-command that wraps pg_upgrade.
  # It handles binary paths, data directory migration, and config updates.
  # See: https://docs.chef.io/supermarket/ctl_supermarket/#pg-upgrade
  run "$SUPERMARKET_CTL pg-upgrade --version '$TARGET_PG_VERSION'"

  info "Embedded PostgreSQL upgrade complete."
  info "Starting PostgreSQL only to verify it comes up cleanly ..."
  run "$SUPERMARKET_CTL start postgresql"
  $DRY_RUN || sleep 5
  run "$SUPERMARKET_CTL status postgresql"
}

# ── Step 3b: Upgrade Docker container ────────────────────────────────────────
upgrade_docker_container() {
  info "=== Step 3: Replacing Docker container with $DOCKER_IMAGE ==="

  command -v docker &>/dev/null || die "docker command not found."

  if [[ -n "$DOCKER_COMPOSE_FILE" && -f "$DOCKER_COMPOSE_FILE" ]]; then
    info "Docker Compose file found at $DOCKER_COMPOSE_FILE"
    info "Updating image reference in compose file ..."

    # Back up the compose file before editing
    run "cp '$DOCKER_COMPOSE_FILE' '${DOCKER_COMPOSE_FILE}.bak.${TIMESTAMP}'"

    # Replace the postgres image line (handles image: postgres:XX patterns)
    run "sed -i 's|image: postgres:[^ ]*|image: ${DOCKER_IMAGE}|g' '$DOCKER_COMPOSE_FILE'"

    info "Pulling new image ..."
    run "docker compose -f '$DOCKER_COMPOSE_FILE' pull"

    info "Recreating container ..."
    run "docker compose -f '$DOCKER_COMPOSE_FILE' up -d --force-recreate --no-deps postgres"

  else
    # Plain docker run — reconstruct the run command from the existing container
    info "Inspecting existing container: $DOCKER_CONTAINER ..."
    local old_image volume_mounts env_vars net ports

    if ! $DRY_RUN; then
      old_image=$(docker inspect --format '{{.Config.Image}}' "$DOCKER_CONTAINER")
      info "Old image: $old_image"
      info "New image: $DOCKER_IMAGE"

      # Collect volume mounts
      volume_mounts=$(docker inspect --format \
        '{{range .Mounts}}-v {{.Source}}:{{.Destination}} {{end}}' \
        "$DOCKER_CONTAINER")

      # Collect environment variables (excluding auto-generated ones)
      env_vars=$(docker inspect --format \
        '{{range .Config.Env}}-e {{.}} {{end}}' \
        "$DOCKER_CONTAINER" | tr ' ' '\n' \
        | grep -v 'PATH=' | grep -v 'GOSU_VERSION=' | grep -v 'LANG=' \
        | grep -v 'PG_VERSION=' | grep -v 'PG_SHA256=' \
        | tr '\n' ' ')

      # Network and port bindings
      net=$(docker inspect --format '{{.HostConfig.NetworkMode}}' "$DOCKER_CONTAINER")
      ports=$(docker inspect --format \
        '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}-p {{(index $conf 0).HostPort}}:{{$p}} {{end}}{{end}}' \
        "$DOCKER_CONTAINER")
    fi

    info "Pulling new image: $DOCKER_IMAGE ..."
    run "docker pull '$DOCKER_IMAGE'"

    info "Stopping old container ..."
    run "docker stop '$DOCKER_CONTAINER'"

    info "Removing old container (volumes are preserved) ..."
    run "docker rm '$DOCKER_CONTAINER'"

    info "Starting new container with $DOCKER_IMAGE ..."
    if $DRY_RUN; then
      echo -e "${YELLOW}[DRY-RUN]${NC} docker run -d --name '$DOCKER_CONTAINER' [volumes] [env] [ports] '$DOCKER_IMAGE'"
    else
      # shellcheck disable=SC2086
      docker run -d \
        --name "$DOCKER_CONTAINER" \
        --network "$net" \
        $volume_mounts \
        $env_vars \
        $ports \
        --restart unless-stopped \
        "$DOCKER_IMAGE" \
        || die "Failed to start new PostgreSQL container."
    fi
  fi

  info "Waiting for PostgreSQL to accept connections ..."
  if ! $DRY_RUN; then
    local retries=30
    until PGPASSWORD="${PGPASSWORD:-}" "$PSQL" \
            -h "$PG_HOST" -p "$PG_PORT" \
            -U "$PG_USER" -d postgres \
            -c "SELECT 1" &>/dev/null; do
      retries=$((retries - 1))
      [[ $retries -le 0 ]] && die "PostgreSQL did not become ready after 30 attempts."
      echo "  Waiting for PostgreSQL ... ($retries retries left)"
      sleep 2
    done
    info "PostgreSQL is accepting connections."
  fi
}

# ── Step 3c: Upgrade external package install ─────────────────────────────────
upgrade_external_package() {
  info "=== Step 3: Upgrading external PostgreSQL package to version $TARGET_PG_VERSION ==="
  warn "This section provides guidance commands — review carefully before running."
  warn "A full pg_upgrade is complex; the safest path for external DBs is dump/restore (already done)."

  if command -v apt-get &>/dev/null; then
    info "Detected apt-based system."
    cat <<INSTRUCTIONS

  # Add the PostgreSQL apt repository if not already present:
  #   curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
  #   echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt \$(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
  #   apt-get update

  # Install new PostgreSQL version:
  #   apt-get install -y postgresql-${TARGET_PG_VERSION}

  # Run pg_upgrade:
  #   su - postgres -c "
  #     /usr/lib/postgresql/${TARGET_PG_VERSION}/bin/pg_upgrade \\
  #       --old-datadir=/var/lib/postgresql/${PG_VERSION}/main \\
  #       --new-datadir=/var/lib/postgresql/${TARGET_PG_VERSION}/main \\
  #       --old-bindir=/usr/lib/postgresql/${PG_VERSION}/bin \\
  #       --new-bindir=/usr/lib/postgresql/${TARGET_PG_VERSION}/bin
  #   "

INSTRUCTIONS
  elif command -v yum &>/dev/null || command -v dnf &>/dev/null; then
    local pkg_cmd; pkg_cmd=$(command -v dnf 2>/dev/null || echo "yum")
    info "Detected yum/dnf-based system."
    cat <<INSTRUCTIONS

  # Install the PostgreSQL ${TARGET_PG_VERSION} repo:
  #   ${pkg_cmd} install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-\$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  #   ${pkg_cmd} -qy module disable postgresql  # if on EL8+

  # Install new PostgreSQL version:
  #   ${pkg_cmd} install -y postgresql${TARGET_PG_VERSION}-server postgresql${TARGET_PG_VERSION}

  # Run pg_upgrade:
  #   /usr/pgsql-${TARGET_PG_VERSION}/bin/postgresql-${TARGET_PG_VERSION}-setup initdb
  #   su - postgres -c "
  #     /usr/pgsql-${TARGET_PG_VERSION}/bin/pg_upgrade \\
  #       --old-datadir=/var/lib/pgsql/${PG_VERSION}/data \\
  #       --new-datadir=/var/lib/pgsql/${TARGET_PG_VERSION}/data \\
  #       --old-bindir=/usr/pgsql-${PG_VERSION}/bin \\
  #       --new-bindir=/usr/pgsql-${TARGET_PG_VERSION}/bin
  #   "

INSTRUCTIONS
  fi

  warn "After pg_upgrade completes, start the new PostgreSQL service and continue."
  warn "The script will pause here — press ENTER once the new PostgreSQL service is running."
  if ! $DRY_RUN; then
    read -rp "  Press ENTER to continue once PostgreSQL $TARGET_PG_VERSION is running ... "
  fi
}

# ── Step 4: Ensure extensions exist ──────────────────────────────────────────
ensure_extensions() {
  info "=== Step 4: Ensuring PostgreSQL extensions are enabled ==="

  local sql="CREATE EXTENSION IF NOT EXISTS plpgsql;
             CREATE EXTENSION IF NOT EXISTS pg_trgm;"

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} psql -c \"$sql\""
  else
    PGPASSWORD="${PGPASSWORD:-}" "$PSQL" \
      -h "$PG_HOST" -p "$PG_PORT" \
      -U "$PG_USER" -d "$PG_DATABASE" \
      -c "$sql" \
      || warn "Extension check failed — the database may not exist yet (will be created at restore)."
  fi
}

# ── Step 5: Restore data ──────────────────────────────────────────────────────
restore_database() {
  info "=== Step 5: Restoring database from backup ==="

  if [[ ! -f "$DUMP_FILE" && ! $DRY_RUN ]]; then
    die "Dump file not found: $DUMP_FILE"
  fi

  info "Dump file: $DUMP_FILE"

  # Drop and recreate the database so the restore starts clean
  local recreate_sql="
    SELECT pg_terminate_backend(pid)
      FROM pg_stat_activity
     WHERE datname = '$PG_DATABASE' AND pid <> pg_backend_pid();
    DROP DATABASE IF EXISTS ${PG_DATABASE};
    CREATE DATABASE ${PG_DATABASE} OWNER ${PG_USER};
  "

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} psql (postgres) -c [drop/create $PG_DATABASE]"
    echo -e "${YELLOW}[DRY-RUN]${NC} pg_restore --host ... --dbname $PG_DATABASE $DUMP_FILE"
  else
    PGPASSWORD="${PGPASSWORD:-}" "$PSQL" \
      -h "$PG_HOST" -p "$PG_PORT" \
      -U "$PG_USER" -d postgres \
      -c "$recreate_sql" \
      || die "Failed to drop/recreate database."

    # Restore extensions into the fresh database before pg_restore loads data
    PGPASSWORD="${PGPASSWORD:-}" "$PSQL" \
      -h "$PG_HOST" -p "$PG_PORT" \
      -U "$PG_USER" -d "$PG_DATABASE" \
      -c "CREATE EXTENSION IF NOT EXISTS plpgsql; CREATE EXTENSION IF NOT EXISTS pg_trgm;" \
      || warn "Extension creation on new database failed — pg_restore may still succeed."

    PGPASSWORD="${PGPASSWORD:-}" "$PGRESTORE" \
      --host="$PG_HOST" \
      --port="$PG_PORT" \
      --username="$PG_USER" \
      --dbname="$PG_DATABASE" \
      --no-password \
      --verbose \
      --clean \
      --if-exists \
      "$DUMP_FILE" \
      || die "pg_restore failed — data has NOT been reloaded. Backup is safe at: $DUMP_FILE"

    info "Database restore complete."
  fi
}

# ── Step 6: Reconfigure and restart Supermarket ───────────────────────────────
restart_supermarket() {
  info "=== Step 6: Reconfiguring and restarting Supermarket ==="

  if [[ -x "$SUPERMARKET_CTL" ]]; then
    info "Running supermarket-ctl reconfigure ..."
    run "$SUPERMARKET_CTL reconfigure"

    info "Starting all Supermarket services ..."
    run "$SUPERMARKET_CTL start"

    $DRY_RUN || sleep 10

    info "Service status:"
    run "$SUPERMARKET_CTL status"
  else
    warn "supermarket-ctl not found — start Supermarket services manually."
  fi
}

# ── Step 7: Smoke test ────────────────────────────────────────────────────────
smoke_test() {
  info "=== Step 7: Smoke test ==="

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} psql -c 'SELECT version(); SELECT count(*) FROM cookbooks;'"
    return
  fi

  local pg_version cookbook_count
  pg_version=$(PGPASSWORD="${PGPASSWORD:-}" "$PSQL" \
    -h "$PG_HOST" -p "$PG_PORT" \
    -U "$PG_USER" -d "$PG_DATABASE" \
    -t -c "SELECT version();" 2>/dev/null | xargs)

  cookbook_count=$(PGPASSWORD="${PGPASSWORD:-}" "$PSQL" \
    -h "$PG_HOST" -p "$PG_PORT" \
    -U "$PG_USER" -d "$PG_DATABASE" \
    -t -c "SELECT count(*) FROM cookbooks;" 2>/dev/null | xargs)

  info "PostgreSQL version: $pg_version"
  info "Cookbook count   : $cookbook_count"

  if [[ -n "$cookbook_count" && "$cookbook_count" -ge 0 ]]; then
    info "✅  Smoke test passed."
  else
    warn "⚠️  Could not query cookbooks table — manual verification recommended."
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo ""
  info "============================================================"
  info " Supermarket PostgreSQL Upgrade Script"
  info " $(date)"
  info "============================================================"
  echo ""

  $DRY_RUN && warn "DRY-RUN mode enabled — no changes will be made."

  preflight
  parse_config
  resolve_pg_binaries

  # Confirm before proceeding
  if ! $DRY_RUN; then
    echo ""
    warn "This will STOP Supermarket, DUMP the database, upgrade PostgreSQL"
    warn "to version $TARGET_PG_VERSION, and RESTORE data."
    warn "Backup will be written to: $DUMP_FILE"
    echo ""
    read -rp "Type 'yes' to continue: " confirm
    [[ "$confirm" == "yes" ]] || die "Aborted by user."
  fi

  stop_supermarket
  backup_database

  if $SKIP_RESTORE; then
    warn "--skip-restore flag set: skipping upgrade and restore steps."
    info "Backup is at: $DUMP_FILE"
    info "Restarting Supermarket services ..."
    restart_supermarket
    exit 0
  fi

  # Upgrade step depends on deployment mode
  case "$PG_MODE" in
    embedded)          upgrade_embedded ;;
    docker)            upgrade_docker_container ;;
    external_package)  upgrade_external_package ;;
    *) die "Unknown deployment mode: $PG_MODE" ;;
  esac

  # For docker and external modes, the dump/restore is the upgrade mechanism
  # (pg_upgrade is only used for embedded). For embedded, data is migrated
  # in-place by pg_upgrade, so restore is skipped.
  if [[ "$PG_MODE" == "embedded" ]]; then
    ensure_extensions
    info "Embedded upgrade uses pg_upgrade (in-place data migration)."
    info "Skipping pg_restore — data is already present."
  else
    ensure_extensions
    restore_database
  fi

  restart_supermarket
  smoke_test

  echo ""
  info "============================================================"
  info " Upgrade complete!"
  info " Backup retained at: $DUMP_FILE"
  info " Review logs at:     /var/log/supermarket/"
  info "============================================================"
  echo ""
}

main "$@"
