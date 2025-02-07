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

name "postgresql17"

default_version "17.2"

license "PostgreSQL"
license_file "COPYRIGHT"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"
dependency "libossp-uuid"
dependency "config_guess"
dependency "icu"
dependency "flex"
dependency "perl"

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"
version("17.2") { source sha256: "82ef27c0af3751695d7f64e2d963583005fbb6a0c3df63d0e4b42211d7021164" }

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
          " --without-docdir" \
          "  --without-docs" \
          " --with-includes=#{install_dir}/embedded/include" \
          " --with-libraries=#{install_dir}/embedded/lib", env: env

  make "install -j #{workers}", env: env
  make "install-pl install-contrib -j #{workers}", env: env

  block do
    Dir.glob("#{install_dir}/embedded/postgresql/#{short_version}/bin/*").sort.each do |bin|
      link bin, "#{install_dir}/embedded/bin/#{File.basename(bin)}"
    end

    delete "#{install_dir}/embedded/postgresql/#{short_version}/share/doc"
  end
end
