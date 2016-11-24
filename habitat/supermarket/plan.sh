pkg_name=supermarket
pkg_version=_computed_below
pkg_origin=robbkidd
pkg_maintainer="Supermarket Team <supermarket@chef.io>"
pkg_license=('Apache-2.0')
pkg_source=not_downloaded
pkg_filename=_computed_below
pkg_bin_dirs=(dist/bin)

pkg_deps=(
  core/bundler
  core/cacerts
  core/gcc-libs
  core/glibc
  core/libffi
  core/libxml2
  core/libxslt
  core/libyaml
  core/node
  core/openssl
  core/postgresql
  core/ruby
  core/zlib
)

pkg_build_deps=(
  core/coreutils
  core/gcc
  core/git
  core/make
  core/rsync
  core/sqlite
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_expose=(13000)

determine_version() {
  pkg_version=$(git describe)
  pkg_dirname=${pkg_name}-${pkg_version}
  pkg_filename=${pkg_dirname}.tar.gz
  pkg_prefix=$HAB_PKG_PATH/${pkg_origin}/${pkg_name}/${pkg_version}/${pkg_release}
  pkg_artifact="$HAB_CACHE_ARTIFACT_PATH/${pkg_origin}-${pkg_name}-${pkg_version}-${pkg_release}-${pkg_target}.${_artifact_ext}"
}

do_download() {
  determine_version

  build_line "Fake download! Creating archive of latest repository commit."
  # source is in this repo, so we're going to create an archive from the
  # appropriate path within the repo for the rest of the plan callback chain
  # to pick up on
  cd $PLAN_CONTEXT/../..
  git archive --prefix=${pkg_name}-${pkg_version}/ --output=$HAB_CACHE_SRC_PATH/${pkg_filename} HEAD src/
}

do_verify() {
  build_line "Skipping checksum verification on the archive we just created."
  return 0
}

# The configure scripts for some RubyGems that build native extensions
# use `/usr/bin` paths for commands. This is not going to work in a
# studio where we don't have any of those commands. But we're kind of
# stuck because the native extension is going to be built during
# `bundle install`.
#
# We clean this link up in `do_install`.
do_prepare() {
  build_line "Setting link for /usr/bin/env to 'coreutils'"
  if [[ ! -r /usr/bin/env ]]; then
    ln -sv $(pkg_path_for coreutils)/bin/env /usr/bin/env
    _clean_env=true
  fi
  return 0
}

do_build() {
  local _source_root=${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}/src/supermarket
  cd ${_source_root}

  local _bundler_dir=$(pkg_path_for bundler)
  local _libxml2_dir=$(pkg_path_for libxml2)
  local _libxslt_dir=$(pkg_path_for libxslt)
  local _postgresql_dir=$(pkg_path_for postgresql)
  local _pgconfig=$_postgresql_dir/bin/pg_config
  local _sqlite_dir=$(pkg_path_for sqlite)
  local _zlib_dir=$(pkg_path_for zlib)

  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"
  export GEM_HOME=${_source_root}/vendor/bundle/ruby/2.3.0
  export GEM_PATH=${GEM_HOME}:${_bundler_dir}:$(pkg_path_for core/ruby)/lib/ruby/gems/2.3.0
  export BUNDLE_SILENCE_ROOT_WARNING=1

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  export NOKOGIRI_CONFIG="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"

  export SQLITE3_CONFIG="--with-sqlite3-include=${_sqlite_dir}/include --with-sqlite3-lib=${_sqlite_dir}/lib --with-sqlite3-dir=${_sqlite_dir}/bin"
  bundle config build.sqlite3 '${SQLITE3_CONFIG}'

  export SSL_CERT_FILE="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"


  bundle config build.nokogiri '${NOKOGIRI_CONFIG}'
  bundle config build.pg --with-pg-config=${_pgconfig}
  bundle config retry 5
  bundle config --local path vendor/bundle
  bundle config --local cache_path vendor/cache
  bundle config --local without development:test
  bundle config --local binstubs true
  bundle config --local cache_all true

  # We need to add tzinfo-data to the Gemfile since we're not in an
  # environment that has this from the OS
  if [[ -z "`grep 'gem .*tzinfo-data.*' Gemfile`" ]]; then
    echo 'gem "tzinfo-data"' >> Gemfile
  fi
  bundle lock --update tzinfo-data

  build_line "Retrieving and caching gems."
  bundle package --all
  build_line "Fixing bundler not locking to the cached copy of Fieri."
  sed -e "s#\.\./fieri#vendor/cache/fieri#" -i Gemfile
  sed -e "s#\.\./fieri#vendor/cache/fieri#" -i Gemfile.lock
  build_line "Creating binstubs and setting bundler to deployment mode."
  bundle install --binstubs --deployment --local --frozen

  attach

  build_line "Compiling assets."
  export DATABASE_URL="postgresql://nobody@nowhere/fake_db_to_appease_rails_env"
  bundle exec rake assets:precompile RAILS_ENV=production

  build_line "Removing legacy default environment."
  rm .env

  build_line "Writing out runtime environment settings."
  _app_run_dir="${pkg_prefix}/dist"
  _runtime_gem_home="${_app_run_dir}/vendor/bundle/ruby/2.3.0"
  cat > runtime_environment.sh <<GEMFILE
export APP_RUN_DIR="${_app_run_dir}"
export GEM_HOME="${_runtime_gem_home}"
export GEM_PATH="${_runtime_gem_home}:$(pkg_path_for core/bundler):$(pkg_path_for core/ruby)/lib/ruby/gems/2.3.0"
export LD_LIBRARY_PATH="$(pkg_path_for core/gcc-libs)/lib"
export SSL_CERT_FILE="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
export NEW_RELIC_LOG_FILE_PATH="${pkg_svc_var_path}"
export RAILS_ENV="production"
GEMFILE
}

do_install() {
  build_line "Lifting files over to the runtime directory."
  rsync -a --info=progress2 src/supermarket/ ${pkg_prefix}/dist

  build_line "Fixing shebangery for production."
  for binstub in ${_app_run_dir}/bin/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ruby)/bin/ruby#" -i $binstub
  done
}

do_end() {
  # Clean up the `env` link, if we set it up. 
  if [[ -n "$_clean_env" ]]; then
    rm -fv /usr/bin/env
  fi
  return 0
}
