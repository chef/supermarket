pkg_name=supermarket-sidekiq
pkg_origin="chef"
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_license=('Apache-2.0')
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

pkg_binds=(
  [rails]="fieri-url port fqdn force-ssl"
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
scaffolding_env[DATABASE_URL]="$db"
scaffolding_env[FIERI_KEY]="{{ cfg.fieri.key }}"
scaffolding_env[FIERI_SUPERMARKET_ENDPOINT]="http{{ #if bind.rails.first.cfg.force_ssl }}s{{ /if }}://localhost:{{ bind.rails.first.cfg.port }}"
scaffolding_env[FIERI_URL]="{{ bind.rails.first.cfg.fieri-url }}"
scaffolding_env[FQDN]="{{ #if cfg.rails.fqdn }}{{ cfg.rails.fqdn }}{{ else }}{{ bind.rails.first.cfg.fqdn }}{{ /if }}"
scaffolding_env[GITHUB_ACCESS_TOKEN]="{{ cfg.github.access_token }}"
scaffolding_env[GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL]="{{ cfg.github.access_token_url }}"
scaffolding_env[GITHUB_CLIENT_OPTION_AUTHORIZE_URL]="{{ cfg.github.option_authorize_url }}"
scaffolding_env[GITHUB_CLIENT_OPTION_SITE]="{{ cfg.github.option_site }}"
scaffolding_env[GITHUB_ENTERPRISE_URL]="{{ cfg.github.enterprise_url }}"
scaffolding_env[GITHUB_KEY]="{{ cfg.github.key }}"
scaffolding_env[GITHUB_SECRET]="{{ cfg.github.secret }}"
scaffolding_env[GITHUB_URL]="{{ cfg.github.url }}"
scaffolding_env[PORT]="{{ bind.rails.first.cfg.port }}"
scaffolding_env[REDIS_URL]="$redis"
scaffolding_env[SMTP_ADDRESS]="{{ cfg.smtp.address }}"
scaffolding_env[SMTP_PASSWORD]="{{ cfg.smtp.password }}"
scaffolding_env[SMTP_PORT]="{{ cfg.smtp.port }}"
scaffolding_env[SMTP_USER_NAME]="{{ cfg.smtp.username }}"

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
