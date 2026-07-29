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

name "supermarket-cookbooks"
license :project_license

source path: "cookbooks/omnibus-supermarket"

build do
  cookbooks_path = "#{install_dir}/embedded/cookbooks"
  env = with_standard_compiler_flags(with_embedded_path)
  # See supermarket.rb: keep native gems buildable on glibc < 2.29 (Amazon Linux 2).
  env["BUNDLE_FORCE_RUBY_PLATFORM"] = "true"

  # `gem install --platform ruby` only constrains the named gem, not its
  # transitive dependencies. Berkshelf pulls in ffi, and the precompiled
  # `x86_64-linux-gnu` build of ffi links against GLIBC_2.27, which Amazon
  # Linux 2 (glibc 2.26) cannot load. Because it lands in the shared embedded
  # gem path it also breaks chef-client at reconfigure time. Install ffi from
  # source first so Berkshelf resolves against it instead.
  gem "install ffi --platform ruby --no-document", env: env
  gem "install berkshelf --platform ruby --no-document", env: env
  command "berks vendor #{cookbooks_path}", env: env

  block do
    all_the_gem_deps = {}
    Dir.glob(cookbooks_path + '/**/metadata.json').each do |metadata|
      cookbook_name = File.basename(File.dirname(metadata))
      metadata_json = FFI_Yajl::Parser.parse(File.read(metadata))
      gem_deps = metadata_json.fetch('gems', [])
      all_the_gem_deps[cookbook_name] = gem_deps unless gem_deps.empty?
    end

    unless all_the_gem_deps.empty?
      raise Omnibus::Error, "Nope. Gem dependencies found in the following cookbooks used during ctl-reconfigure. This will break airgapped installs.\n#{all_the_gem_deps}"
    end
  end

  block do
    open("#{cookbooks_path}/dna.json", "w") do |file|
      file.write FFI_Yajl::Encoder.encode(run_list: ['recipe[omnibus-supermarket::default]'])
    end

    open("#{cookbooks_path}/show-config.json", "w") do |file|
      file.write FFI_Yajl::Encoder.encode(
        run_list: ['recipe[omnibus-supermarket::show_config]']
      )
    end

    open("#{cookbooks_path}/solo.rb", "w") do |file|
      file.write <<-EOH.gsub(/^ {8}/, '')
        cookbook_path   "#{cookbooks_path}"
        cache_path "/var/opt/supermarket/cache"
        verbose_logging true
        ssl_verify_mode :verify_peer
      EOH
    end
  end
end
