#
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
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

name "more-ruby-cleanup-supermarket"

skip_transitive_dependency_licensing true
license :project_license

source path: "#{project.files_path}/#{name}"

dependency "ruby"

build do
  block "Delete bundler git cache, docs, and build info" do
    remove_directory "#{install_dir}/embedded/service/supermarket/vendor/cache"

    # this expands into the appropriate Ruby release number dir
    vendor_ruby_dir = File.expand_path("#{install_dir}/embedded/service/supermarket/vendor/bundle/ruby/*")

    remove_directory "#{vendor_ruby_dir}/build_info"
    # scanning for individual ruby version directory and
    # then deleting the target folders under that as
    # remove_directory doesn't work for wildcards
    Dir.glob(vendor_ruby_dir).each do |ruby_version_dir|
      puts "removing cache under: #{ruby_version_dir}"
      remove_directory "#{ruby_version_dir}/cache"
      puts "removing doc under: #{ruby_version_dir}"
      remove_directory "#{ruby_version_dir}/doc"
    end
  end
end
