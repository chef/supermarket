#
# Copyright 2014 Chef Software, Inc.
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

name "supermarket"
default_version "1.0.0"

dependency "bundler"
dependency "git"
dependency "postgresql"
dependency "redis"
dependency "ruby"

source git: "https://github.com/opscode/supermarket.git"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install" \
         " --jobs 4" \
         " --path=vendor/bundle" \
         " --without development",
         env: env
  # This fails because we're installing Ruby C extensions in the wrong place!
  #bundle "exec rake assets:precompile", env: env

  sync project_dir, "#{install_dir}/embedded/service/supermarket/"
  delete "#{install_dir}/embedded/service/supermarket/log"
  delete "#{install_dir}/embedded/service/supermarket/tmp"
end
