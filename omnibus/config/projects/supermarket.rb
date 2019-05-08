#
# Copyright 2014-2016 Chef Software, Inc.
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
maintainer "Chef Supermarket Team <supermarket@chef.io>"
homepage "https://supermarket.chef.io"

license "Chef EULA"
license_file "CHEF-EULA.md"

# Defaults to C:/supermarket on Windows
# and /opt/supermarket on all other platforms
install_dir "#{default_root}/#{name}"

build_version   IO.read(File.expand_path("../../../../VERSION", __FILE__)).strip
build_iteration 1

override :postgresql, version: '9.3.18'
override :ruby, version: "2.5.3"
override :'chef-gem', version: '14.5.33'
override :berkshelf, version: 'v6.3.1'
override :'openssl-fips', version: '2.0.16'
override :inspec, version: 'v3.9.2' # TODO: remove when license_acceptance is added

# Creates required build directories
dependency "preparation"

# supermarket dependencies/components
dependency "supermarket"
dependency "supermarket-cookbooks"
dependency "supermarket-ctl"

# Version manifest file
dependency "version-manifest"

# remove lots of ruby clutter we don't need
dependency "ruby-cleanup"

exclude "**/.git"
exclude "**/bundler/git"

package :deb do
  compression_level 1
  compression_type :xz
end

package :rpm do
  signing_passphrase ENV['OMNIBUS_RPM_SIGNING_PASSPHRASE']
  compression_level 1
  compression_type :xz
end
