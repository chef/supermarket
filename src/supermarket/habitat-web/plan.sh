pkg_name=supermarket
pkg_origin="chef"
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_license=("Apache-2.0")
pkg_scaffolding="core/scaffolding-ruby"
pkg_description="Supermarket is Chef's community repository for cookbooks, currently hosted at supermarket.chef.io.
Supermarket can also run internally, behind-the-firewall."
pkg_upstream_url="https://docs.chef.io/supermarket/#private-supermarket"
pkg_deps=(core/coreutils core/bash core/file core/glibc core/gcc-libs core/libarchive core/shared-mime-info)
pkg_build_deps=(core/phantomjs core/yarn)
pkg_svc_user="root"
pkg_svc_group="root"
scaffolding_ruby_pkg="core/ruby27"

pkg_binds_optional=(
  [database]="port username password"
  [redis]="port"
)

pkg_exports=(
  [port]=app.port
  [http-port]=nginx.port
  [https-port]=nginx.ssl_port
  [force-ssl]=nginx.force_ssl
  [fqdn]=app.fqdn
  [fqdn-sanitized]=app.fqdn_sanitized
  [fieri-url]=fieri.url
)

db="postgresql://{{ #if bind.database }}{{ bind.database.first.cfg.username }}{{ else }}{{ cfg.db.user }}{{ /if }}"
db="${db}:{{ #if bind.database }}{{ bind.database.first.cfg.password }}{{ else }}{{ cfg.db.password }}{{ /if }}"
db="${db}@{{ #if bind.database }}{{ bind.database.first.sys.ip }}{{ else }}{{ cfg.db.host }}{{ /if }}"
db="${db}:{{ #if bind.database }}{{ bind.database.first.cfg.port }}{{ else }}{{ cfg.db.port }}{{ /if }}"
db="${db}/{{ cfg.db.name }}_{{ cfg.rails_env }}"

redis="redis://{{ #if bind.redis }}{{ bind.redis.first.sys.ip }}{{ else }}{{ cfg.redis.host }}{{ /if }}"
redis="${redis}:{{ #if bind.redis }}{{ bind.redis.first.cfg.port }}{{ else }}{{ cfg.redis.port }}{{ /if }}"
redis="${redis}/{{ cfg.redis.database }}"

declare -A scaffolding_env
scaffolding_env[AIR_GAPPED]="{{ cfg.app.air_gapped_flag }}"
scaffolding_env[ANNOUNCEMENT_BANNER]="{{ cfg.app.announcement.banner_enabled }}"
scaffolding_env[ANNOUNCEMENT_TEXT]="{{ cfg.app.announcement.text }}"
scaffolding_env[API_ITEM_LIMIT]="{{ cfg.app.api_item_limit }}"
scaffolding_env[BACKTRACE]="{{ cfg.backtrace }}"
scaffolding_env[BUNDLE_GEMFILE]="{{ pkg.path }}/app/Gemfile"
scaffolding_env[CDN_URL]="{{ cfg.s3.cdn_url }}"
scaffolding_env[CHEF_BLOG_URL]="{{ cfg.urls.chef_blog_url }}"
scaffolding_env[CHEF_DOCS_URL]="{{ cfg.urls.chef_docs_url }}"
scaffolding_env[CHEF_DOMAIN]="{{ cfg.urls.chef_domain }}"
scaffolding_env[CHEF_DOWNLOADS_URL]="{{ cfg.urls.chef_downloads_url }}"
scaffolding_env[CHEF_IDENTITY_URL]="{{ #if cfg.urls.chef_identity_url }}{{ cfg.urls.chef_identity_url }}{{ else }}{{ cfg.app.chef_server_url }}/id{{ /if }}"
scaffolding_env[CHEF_MANAGE_URL]="{{ #if cfg.urls.chef_manage_url }}{{ cfg.urls.chef_manage_url }}{{ else }}{{ cfg.app.chef_server_url }}{{ /if }}"
scaffolding_env[CHEF_OAUTH2_APP_ID]="{{ cfg.oauth2.app_id }}"
scaffolding_env[CHEF_OAUTH2_SECRET]="{{ cfg.oauth2.secret }}"
scaffolding_env[CHEF_OAUTH2_URL]="{{ #if cfg.oauth2.url }}{{ cfg.oauth2.url }}{{ else }}{{ cfg.app.chef_server_url }}{{ /if }}"
scaffolding_env[CHEF_OAUTH2_VERIFY_SSL]="{{ cfg.oauth2.verify_ssl }}"
scaffolding_env[CHEF_PROFILE_URL]="{{ #if cfg.urls.chef_profile_url }}{{ cfg.urls.chef_profile_url }}{{ else }}{{ cfg.app.chef_server_url }}{{ /if }}"
scaffolding_env[CHEF_SERVER_URL]="{{ cfg.app.chef_server_url }}"
scaffolding_env[CHEF_SIGN_UP_URL]="{{ #if cfg.urls.chef_sign_up_url }}{{ cfg.urls.chef_sign_up_url }}{{ else }}{{ cfg.app.chef_server_url }}/signup?ref=community{{ /if }}"
scaffolding_env[CHEF_STATUS_URL]="{{ cfg.urls.chef_status_url }}"
scaffolding_env[CHEF_TRAINING_URL]="{{ cfg.urls.chef_training_url }}"
scaffolding_env[CHEF_WWW_URL]="{{ cfg.urls.chef_www_url }}"
scaffolding_env[DATABASE_URL]="$db"
scaffolding_env[DATADOG_APP_NAME]="{{ cfg.datadog.app_name }}"
scaffolding_env[DATADOG_ENVIRONMENT]="{{ cfg.rails_env }}"
scaffolding_env[DATADOG_TRACER_ENABLED]="{{ cfg.datadog.tracer_enabled }}"
scaffolding_env[ENFORCE_PRIVACY]="{{ cfg.app.enforce_privacy }}"
scaffolding_env[FEATURES]="{{ strJoin cfg.app.features \", \" }}"
scaffolding_env[FIERI_FOODCRITIC_FAIL_TAGS]="{{ cfg.fieri.foodcritic_fail_tags }}"
scaffolding_env[FIERI_FOODCRITIC_TAGS]="{{ cfg.fieri.foodcritic_tags }}"
scaffolding_env[FIERI_KEY]="{{ cfg.fieri.key }}"
scaffolding_env[FIERI_SUPERMARKET_ENDPOINT]="http{{ #if cfg.nginx.force_ssl }}s{{ /if }}://localhost:{{ cfg.app.port }}"
scaffolding_env[FIERI_URL]="{{ cfg.fieri.url }}"
scaffolding_env[FIPS_ENABLED]="{{ cfg.fips.enabled }}"
scaffolding_env[FORCE_SSL]="{{ cfg.ssl.force_ssl }}"
scaffolding_env[FQDN]="{{ #if cfg.app.fqdn }}{{ cfg.app.fqdn }}{{ else }}{{ sys.hostname }}{{ /if }}"
scaffolding_env[FROM_EMAIL]="{{ cfg.app.from_email }}"
scaffolding_env[GITHUB_ACCESS_TOKEN]="{{ cfg.github.access_token }}"
scaffolding_env[GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL]="{{ cfg.github.access_token_url }}"
scaffolding_env[GITHUB_CLIENT_OPTION_AUTHORIZE_URL]="{{ cfg.github.option_authorize_url }}"
scaffolding_env[GITHUB_CLIENT_OPTION_SITE]="{{ cfg.github.option_site }}"
scaffolding_env[GITHUB_ENTERPRISE_URL]="{{ cfg.github.enterprise_url }}"
scaffolding_env[GITHUB_KEY]="{{ cfg.github.key }}"
scaffolding_env[GITHUB_SECRET]="{{ cfg.github.secret }}"
scaffolding_env[GITHUB_URL]="{{ cfg.github.url }}"
scaffolding_env[GOOGLE_ANALYTICS_ID]="{{ cfg.app.google_analytics_id }}"
scaffolding_env[LEARN_CHEF_URL]="{{ cfg.urls.learn_chef_url }}"
scaffolding_env[LOG_LEVEL]="{{ cfg.app.log_level }}"
scaffolding_env[NEWRELIC_AGENT_ENABLED]="{{ cfg.new_relic.enabled }}"
scaffolding_env[NEW_RELIC_APP_NAME]="{{ cfg.new_relic.app_name }}"
scaffolding_env[NEW_RELIC_APP_NAME]="{{ cfg.new_relic.app_name }}"
scaffolding_env[NEW_RELIC_LICENSE_KEY]="{{ cfg.new_relic.license_key }}"
scaffolding_env[OMNIBUS_FIPS_MODE]="{{ cfg.fips.omnibus_mode }}"
scaffolding_env[OMNIBUS_RPM_SIGNING_PASSPHRASE]="{{ cfg.app.rpm_signing_passphrase }}"
scaffolding_env[OPENSSL_FIPS]="{{ cfg.fips.openssl }}"
scaffolding_env[OWNERS_CAN_REMOVE_ARTIFACTS]="{{ cfg.app.owners_can_remove_artifacts }}"
scaffolding_env[PORT]="{{ #if cfg.nginx.force_ssl }}{{ cfg.nginx.ssl_port }}{{ else }}{{ cfg.nginx.non_ssl_port }}{{ /if }}"
scaffolding_env[PROGRESS_DOMAIN]="{{ cfg.urls.progress_domain }}"
scaffolding_env[PROGRESS_WWW_URL]="{{ cfg.urls.progress_www_url }}"
scaffolding_env[PROTOCOL]="http{{ #if cfg.nginx.force_ssl }}s{{ /if }}"
scaffolding_env[RAILS_LOG_TO_STDOUT]="{{ cfg.app.rails_log_to_stdout }}"
scaffolding_env[RAILS_SERVE_STATIC_FILES]="{{ cfg.app.serve_static_files }}"
scaffolding_env[REDIS_JOBQ_URL]="{{ cfg.redis.jobq_url }}"
scaffolding_env[REDIS_URL]="$redis"
scaffolding_env[ROBOTS_ALLOW]="{{ cfg.robots_allow }}"
scaffolding_env[ROBOTS_DISALLOW]="{{ cfg.robots_disallow }}"
scaffolding_env[S3_ACCESS_KEY_ID]="{{ cfg.s3.access_key_id }}"
scaffolding_env[S3_BUCKET]="{{ cfg.s3.bucket_name }}"
scaffolding_env[S3_DOMAIN_STYLE]="{{ cfg.s3.domain_style }}"
scaffolding_env[S3_ENCRYPTION]="{{ cfg.s3.encryption }}"
scaffolding_env[S3_ENDPOINT]="{{ cfg.s3.endpoint }}"
scaffolding_env[S3_PATH]="{{ cfg.s3.path }}"
scaffolding_env[S3_PRIVATE_OBJECTS]="{{ cfg.s3.private_objects }}"
scaffolding_env[S3_REGION]="{{ cfg.s3.region }}"
scaffolding_env[S3_SECRET_ACCESS_KEY]="{{ cfg.s3.secret_access_key }}"
scaffolding_env[S3_URLS_EXPIRE]="{{ cfg.s3.urls_expire }}"
scaffolding_env[SEGMENT_WRITE_KEY]="{{ cfg.app.segment_write_key }}"
scaffolding_env[SENTRY_URL]="{{ cfg.sentry_url }}"
scaffolding_env[SMTP_ADDRESS]="{{ cfg.smtp.address }}"
scaffolding_env[SMTP_PASSWORD]="{{ cfg.smtp.password }}"
scaffolding_env[SMTP_PORT]="{{ cfg.smtp.port }}"
scaffolding_env[SMTP_USER_NAME]="{{ cfg.smtp.username }}"
scaffolding_env[STATSD_PORT]="{{ cfg.statsd_port }}"
scaffolding_env[STATSD_URL]="{{ cfg.statsd_url }}"
scaffolding_env[cookbook]="{{ cfg.app.cookbook }}"

scaffolding_env[INSTALL_DIRECTORY]="{{ pkg.path }}"
scaffolding_env[INSTALL_PATH]="{{ pkg.path }}"
scaffolding_env[APP_DIRECTORY]="{{ pkg.path }}/app"
scaffolding_env[CONFIG_DIRECTORY]="{{ pkg.svc_config_path }}"
scaffolding_env[LOG_DIRECTORY]="{{ pkg.svc_var_path }}/log"
scaffolding_env[DATA_DIRECTORY]="{{ pkg.svc_data_path }}"
scaffolding_env[VAR_DIRECTORY]="{{ pkg.svc_var_path }}"
scaffolding_env[USER]="{{ pkg.svc_user }}"
scaffolding_env[GROUP]="{{ pkg.svc_group }}"

pkg_version() {
  cat "$PLAN_CONTEXT/../../../VERSION"
}

do_begin() {
  do_default_begin
  update_pkg_version
}

do_setup_environment() {
  set_runtime_env FREEDESKTOP_MIME_TYPES_PATH "$(pkg_path_for core/shared-mime-info)/share/mime/packages/freedesktop.org.xml"
  set_buildtime_env BUNDLE_SHEBANG "$(pkg_path_for "$_ruby_pkg")/bin/ruby"
  set_buildtime_env BUNDLE_DEPLOYMENT true
  set_buildtime_env BUNDLE_JOBS "$(nproc)"
  set_buildtime_env BUNDLE_CLEAN false
  set_buildtime_env BUNDLE_PATH "$CACHE_PATH/vendor/bundle"
}

do_prepare() {
  # Override ruby version detection
  local gem_dir gem_path
  # The install prefix path for the app
  scaffolding_app_prefix="$pkg_prefix/$app_prefix"

  _detect_git

  # Determine Ruby engine, ABI version, and Gem path by running `ruby` itself.
  eval "$(hab pkg exec "${_ruby_pkg}" ruby -- -r rubygems -rrbconfig - <<-'EOF'
    puts "local ruby_engine=#{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'}"
    puts "local ruby_version=#{RbConfig::CONFIG['ruby_version']}"
    puts "local gem_path='#{Gem.path.join(':')}'"
EOF
)"

  # Strip out any home directory entries at the front of the gem path.
  # shellcheck disable=SC2001
  gem_path=$(echo "$gem_path" | sed 's|^/root/\.gem/[^:]\{1,\}:||')
  # Compute gem directory where gems will be ultimately installed to
  gem_dir="$scaffolding_app_prefix/vendor/bundle/$ruby_engine/$ruby_version"
  # Compute gem directory where gems are initially installed to via Bundler
  _cache_gem_dir="$CACHE_PATH/vendor/bundle/$ruby_engine/$ruby_version"

  # Silence Bundler warning when run as root user
  export BUNDLE_SILENCE_ROOT_WARNING=1

  # Attempt to preserve any original Bundler config by moving it to the side
  if [[ -f .bundle/config ]]; then
    build_line "Detecting existing bundler config. Temporarily renaming ..."
    mv .bundle/config .bundle/config.prehab
    dot_bundle=true
  elif [[ -d .bundle ]]; then
    dot_bundle=true
  fi

  GEM_HOME="$gem_dir"
  build_line "Setting GEM_HOME=$GEM_HOME"
  GEM_PATH="$gem_dir:$gem_path"
  build_line "Setting GEM_PATH=$GEM_PATH"
  export GEM_HOME GEM_PATH

  # core/ruby includes its own bundler which is used (2.2.22 at this time) however the scaffolding tries to vendor
  # core/bundler @ version 2.2.14
  _bundler_version="2.2.14"

  bundle config build.ruby-filemagic --with-magic-dir="$(pkg_path_for core/file)"
}

do_after() {
  sed -i "s/{{cfg.db.name}}/{{ cfg.db.name }}_{{ cfg.rails_env }}/" "$pkg_prefix/config/app_env.sh"
  fix_interpreter "$pkg_prefix/app/bin/*" core/coreutils bin/env
  fix_interpreter "$pkg_prefix/app/exec/*" core/coreutils bin/env

  env_sh="$pkg_prefix/config/app_env.sh"
  rm -f "${env_sh}"
  for key in "${!scaffolding_env[@]}"; do
    if [[ "${scaffolding_env[$key]}" =~ ^\{\{[[:space:]](cfg\.[^[:space:]]+)[[:space:]]\}\}$ ]]; then
      echo "{{ #if ${BASH_REMATCH[1]} }}export $key='${scaffolding_env[$key]}'{{ /if }}" >> "$env_sh"
    else
      echo "export $key='${scaffolding_env[$key]}'" >> "$env_sh"
    fi
  done
}

_load_scaffolding() {
  local lib
  if [[ -z "${pkg_scaffolding:-}" ]]; then
    return 0
  fi

  lib="$(_pkg_path_for_build_deps "$pkg_scaffolding")/lib/scaffolding.sh"
  build_line "Loading Scaffolding $lib"
  if ! source "$lib"; then
    exit_with "Failed to load Scaffolding from $lib" 17
  fi

  _rename_function "_detect_rails6_app" "_scaffolding_detect_rails6_app"
  _rename_function "_new_detect_rails6_app" "_detect_rails6_app"
  _rename_function "scaffolding_generate_binstubs" "old_scaffolding_generate_binstubs"
  _rename_function "new_scaffolding_generate_binstubs" "scaffolding_generate_binstubs"
  _rename_function "scaffolding_bundle_install" "old_scaffolding_bundle_install"
  _rename_function "new_scaffolding_bundle_install" "scaffolding_bundle_install"
  _rename_function "_tar_pipe_app_cp_to" "old_tar_pipe_app_cp_to"
  _rename_function "_new_tar_pipe_app_cp_to" "_tar_pipe_app_cp_to"

  SRC_PATH="${PLAN_CONTEXT}/.."

  if [[ "$(type -t scaffolding_load)" == "function" ]]; then
    scaffolding_load
  fi
}

_new_detect_rails6_app() {
  if _has_gem railties && _compare_gem railties \
      --greater-than-eq 6.0.0 --less-than 7.0.0; then
    build_line "Detected Rails 6 app type"
    _app_type="rails6"
    return 0
  else
    return 1
  fi
}

new_scaffolding_generate_binstubs() {
  build_line "Generating app binstubs in $scaffolding_app_prefix/binstubs"
  rm -rf "$scaffolding_app_prefix/.bundle"
  pushd "$scaffolding_app_prefix" &> /dev/null || exit 1
    _bundle binstubs \
      --all \
      --path "$scaffolding_app_prefix/binstubs"
  popd &> /dev/null || exit 1
}

new_scaffolding_bundle_install() {
  local start_sec elapsed

  build_line "Installing dependencies using Bundler version ${_bundler_version}"
  start_sec="$SECONDS"

  {
    _bundle install
  } || {
      _restore_bundle_config
      e="bundler returned an error"
      exit_with "$e" 10
  }

  elapsed=$((SECONDS - start_sec))
  elapsed=$(echo $elapsed | awk '{printf "%dm%ds", $1/60, $1%60}')
  build_line "Bundle completed ($elapsed)"

  # If we preserved the original Bundler config, move it back into place
  if [[ -f .bundle/config.prehab ]]; then
    _restore_bundle_config
  fi
  # If not `.bundle/` directory existed before, then clear it out now
  if [[ -z "${dot_bundle:-}" ]]; then
    rm -rf .bundle
  fi
}

_new_tar_pipe_app_cp_to() {
  local dst_path tar
  dst_path="$1"
  tar="$(pkg_path_for tar)/bin/tar"

  "$tar" -cp \
      --owner=root:0 \
      --group=root:0 \
      --no-xattrs \
      --exclude-backups \
      --exclude-vcs \
      --exclude='.env.test' \
      --exclude='.rubocop.yml' \
      --exclude='Berksfile' \
      --exclude='chef' \
      --exclude='docker-compose.yml' \
      --exclude='docs' \
      --exclude='Guardfile' \
      --exclude='habitat-web' \
      --exclude='habitat-worker' \
      --exclude='results' \
      --exclude='spec' \
      --exclude='vendor/bundle' \
      --files-from=- \
      -f - \
  | "$tar" -x \
      -C "$dst_path" \
      -f -
}
