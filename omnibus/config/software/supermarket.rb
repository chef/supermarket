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
license :project_license

source path: File.expand_path('../../../../src/supermarket', project.filepath)

dependency "bundler"
dependency "cacerts"
dependency "chef-gem"
dependency "git"
dependency "nginx"
dependency "nodejs"
dependency "postgresql"
dependency "redis"
dependency "ruby"
dependency "runit"
dependency "logrotate"
dependency "fieri"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "package --all --no-install"

  bundle "install" \
         " --jobs #{workers}" \
         " --retry 3" \
         " --path=vendor/bundle" \
         " --without development",
         env: env
  # This fails because we're installing Ruby C extensions in the wrong place!
  bundle "exec rake assets:precompile", env: env.merge('RAILS_ENV' => 'production')

  sync project_dir, "#{install_dir}/embedded/service/supermarket/",
    exclude: %w( .cookbooks .direnv .envrc .env.* .gitignore .kitchen*
                 app/assets/**/branding coverage log node_modules pkg
                 public/system spec tmp )
end
