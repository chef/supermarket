pkg_name=supermarket
pkg_version=$(cat ../../VERSION)
pkg_origin=robbkidd
pkg_maintainer="Supermarket Team <supermarket@chef.io>"
pkg_license=('Apache-2.0')
pkg_source=not_downloaded
pkg_filename=${pkg_name}-${pkg_version}.tar.gz

pkg_deps=(
  core/bundler
  core/cacerts
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
pkg_expose=(3000)

do_download() {
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
  [[ ! -f /usr/bin/env ]] && ln -s $(pkg_path_for coreutils)/bin/env /usr/bin/env
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
  export GEM_HOME=${_source_root}/vendor
  export GEM_PATH=${_bundler_dir}:${GEM_HOME}
  export BUNDLE_SILENCE_ROOT_WARNING=1

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  export NOKOGIRI_CONFIG="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"

  export SQLITE3_CONFIG="--with-sqlite3-include=${_sqlite_dir}/include --with-sqlite3-lib=${_sqlite_dir}/lib --with-sqlite3-dir=${_sqlite_dir}/bin"
  bundle config build.sqlite3 '${SQLITE3_CONFIG}'

  export SSL_CERT_FILE="$(hab pkg path core/cacerts)/ssl/certs/cacert.pem"


  bundle config build.nokogiri '${NOKOGIRI_CONFIG}'
  bundle config build.pg --with-pg-config=${_pgconfig}
  bundle config without development:test
  bundle config binstubs true
  bundle config retry 5

  # We need to add tzinfo-data to the Gemfile since we're not in an
  # environment that has this from the OS
  if [[ -z "`grep 'gem .*tzinfo-data.*' Gemfile`" ]]; then
    echo 'gem "tzinfo-data"' >> Gemfile
  fi

  build_line "Retrieving and caching gems."
  bundle package --all
  build_line "Installing only production gems from gem cache."
  bundle install --deployment --local --frozen
  build_line "Compiling assets."
  bundle exec rake assets:precompile RAILS_ENV=production
}

do_install() {
  build_line "Lifting files over to the runtime directory."
  rsync -a --info=progress2 src/supermarket/.* ${pkg_prefix}/dist

  build_line "Fixing shebangery for production."
  for binstub in ${pkg_prefix}/dist/bin/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ruby)/bin/ruby#" -i $binstub
  done

  if [[ `readlink /usr/bin/env` = "$(pkg_path_for coreutils)/bin/env" ]]; then
    build_line "Removing the symlink we created for '/usr/bin/env'"
    rm /usr/bin/env
  fi
}
