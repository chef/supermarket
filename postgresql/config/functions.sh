init_pgpass() {
  cat > {{pkg.svc_var_path}}/.pgpass<<EOF
*:*:*:{{cfg.superuser.name}}:{{cfg.superuser.password}}
*:*:*:{{cfg.replication.name}}:{{cfg.replication.password}}
EOF
chmod 0600 {{pkg.svc_var_path}}/.pgpass
  export PGPASSFILE="{{pkg.svc_var_path}}/.pgpass"
}

write_local_conf() {
  echo 'Writing postgresql.local.conf file based on memory settings'
  cat > {{pkg.svc_config_path}}/postgresql.local.conf<<LOCAL
# Auto-generated memory defaults created at service start by Habitat
maintenance_work_mem=$(awk '/MemTotal/ {printf( "%.0f\n", $2 / 1024 / 16 )}' /proc/meminfo)MB
temp_buffers=$(awk '/MemTotal/ {printf( "%.0f\n", (($2 / 1024 / 4) *3) / ({{cfg.max_connections}}*3) )}' /proc/meminfo)MB
LOCAL
}

write_env_var() {
  echo "$1" > "{{pkg.svc_config_path}}/env/$2"
}

setup_replication_user_in_master() {
  echo 'Making sure replication role exists on Master'
  psql -U {{cfg.superuser.name}}  -h {{svc.leader.sys.ip}} -p {{cfg.port}} postgres >/dev/null 2>&1 << EOF
DO \$$
  BEGIN
  SET synchronous_commit = off;
  PERFORM * FROM pg_authid WHERE rolname = '{{cfg.replication.name}}';
  IF FOUND THEN
    ALTER ROLE "{{cfg.replication.name}}" WITH REPLICATION LOGIN PASSWORD '{{cfg.replication.password}}';
  ELSE
    CREATE ROLE "{{cfg.replication.name}}" WITH REPLICATION LOGIN PASSWORD '{{cfg.replication.password}}';
  END IF;
END;
\$$
EOF
}

local_xlog_position() {
  psql -U {{cfg.superuser.name}} -h localhost -p {{cfg.port}} postgres -t <<EOF | tr -d '[:space:]'
SELECT CASE WHEN pg_is_in_recovery()
  THEN GREATEST(pg_xlog_location_diff(COALESCE(pg_last_xlog_receive_location(), '0/0'), '0/0')::bigint,
                pg_xlog_location_diff(pg_last_xlog_replay_location(), '0/0')::bigint)
  ELSE pg_xlog_location_diff(pg_current_xlog_location(), '0/0')::bigint
END;
EOF
}

master_xlog_position() {
  psql -U {{cfg.superuser.name}} -h {{svc.leader.sys.ip}} -p {{cfg.port}} postgres -t <<EOF | tr -d '[:space:]'
SELECT pg_xlog_location_diff(pg_current_xlog_location(), '0/0')::bigint;
EOF
}

master_ready() {
  pg_isready -U {{cfg.superuser.name}} -h {{svc.leader.sys.ip}} -p {{cfg.port}}
}

bootstrap_replica_via_pg_basebackup() {
  echo 'Bootstrapping replica via pg_basebackup from leader '
  local data_directory
  data_directory='{{ #if cfg.data_directory }}{{ cfg.data_directory }}{{ else }}{{ pkg.svc_data_path }}{{ /if }}/pgdata'
  rm -rf "${data_directory}/*"
  pg_basebackup --verbose --progress --pgdata="${data_directory}" --xlog-method=stream --dbname='postgres://{{cfg.replication.name}}@{{svc.leader.sys.ip}}:{{cfg.port}}/postgres'
}

ensure_dir_ownership() {
  local data_directory
  data_directory='{{ #if cfg.data_directory }}{{ cfg.data_directory }}{{ else }}{{ pkg.svc_data_path }}{{ /if }}'
  paths="{{ pkg.svc_var_path }}"
  paths="${paths} ${data_directory}/pgdata"
  paths="${paths} ${data_directory}/archive"
  if [[ $EUID -eq 0 ]]; then
    # if EUID is root, so we should chown to pkg_svc_user:pkg_svc_group
    ownership_command="chown -RL {{cfg.process.user}}:{{cfg.process.group}} $paths"
  else
    # not root, so at best we can only chgrp to the effective user's primary group
    ownership_command="chgrp -RL $(id -g) $paths"
  fi
  echo "Ensuring proper ownership: $ownership_command"
  $ownership_command
  chmod 0700 {{ #if cfg.data_directory }}{{ cfg.data_directory }}{{ else }}{{ pkg.svc_data_path }}{{ /if }}/pgdata
}

promote_to_leader() {
  if [ -f {{pkg.svc_data_path}}/pgdata/recovery.conf ]; then
    echo "Promoting database"
    until pg_isready -U {{cfg.superuser.name}} -h localhost -p {{cfg.port}}; do
      echo "Waiting for database to start"
      sleep 1
    done

    pg_ctl promote -D {{ #if cfg.data_directory }}{{ cfg.data_directory }}{{ else }}{{ pkg.svc_data_path }}{{ /if }}/pgdata
  fi
}

create_kernel_param() {
  local kernel_param kernel_value filename
  kernel_param="$1"
  kernel_value="$2"
  dirname="/etc/sysctl.d"
  filename="${dirname}/99-habitat-postgres-$(tr "/" "." <<<"${kernel_param}").conf"

  mkdir -p "${dirname}"
  cat > "${filename}" <<CONF
$kernel_param = $kernel_value
CONF
  sysctl -p
}