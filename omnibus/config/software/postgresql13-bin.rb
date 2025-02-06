#
# Copyright:: Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "postgresql13-bin"

default_version "13.4"

license "PostgreSQL"
license_file "COPYRIGHT"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"
dependency "libossp-uuid"
dependency "config_guess"

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"
version("13.4") { source sha256: "ea93e10390245f1ce461a54eb5f99a48d8cabd3a08ce4d652ec2169a357bc0cd" }

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  # short_version = version.gsub(/^([0-9]+).([0-9]+).[0-9]+$/, '\1.\2')
  # We need to consider only the major version for postgres 13
  short_version = version.match(/^([0-9]+)/).to_s

  update_config_guess(target: "config")

  command "./configure" \
          " --prefix=#{install_dir}/embedded/postgresql/#{short_version}" \
          " --with-libedit-preferred" \
          " --with-openssl" \
          " --with-ossp-uuid" \
          " --with-includes=#{install_dir}/embedded/include" \
          " --with-libraries=#{install_dir}/embedded/lib", env: env

  make "world -j #{workers}", env: env

  make "-C src/interfaces/libpq install", env: env  # libpq.so
  make "-C src/backend install-bin", env: env       # postgres binary
  make "-C src/timezone/tznames  install", env: env # share/timezonesets
  make "-C src/bin install", env: env               # pg_*, psql binaries
end
