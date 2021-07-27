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

require 'pry'
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
dependency "file"
dependency "libarchive"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "package --all --no-install"

  bundle "install" \
         " --jobs #{workers}" \
         " --retry 3" \
         " --path=vendor/bundle" \
         " --without development doc",
         env: env

  # tas50 7/20/2021 note: Why do we set S3_REGION us-west-2 here?
  # supermarket includes validation for s3 configurations set by the user to ensure that if either S3_BUCKET or S3_REGION
  # are set that the other is also set. Currently buildkite sets S3_BUCKET and the workaround is to set this var that doesn't
  # get used. I tried removing the var from the env above, but it's not actually set at that point :shrug:. Feel free
  # to solve this in a better way.

  # This fails because we're installing Ruby C extensions in the wrong place!
  #bundle "exec rake assets:precompile", env: env.merge('RAILS_ENV' => 'production', 'S3_REGION' => 'us-west-2', 'S3_BUCKET' => 'opscode-omnibus-cache')
  bundle "exec rake assets:precompile", env: env.merge('RAILS_ENV' => 'production')

  sync project_dir, "#{install_dir}/embedded/service/supermarket/",
    exclude: %w( .cookbooks .direnv .envrc .env.* .gitignore .kitchen*
                 app/assets/**/branding coverage log node_modules pkg
                 public/system spec tmp )
end
