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

dependency "berkshelf"
dependency "cacerts"

source path: "cookbooks/omnibus-supermarket"

build do
  cookbooks_path = "#{install_dir}/embedded/cookbooks"
  env = with_standard_compiler_flags(with_embedded_path)

  # FIXME: Berks fails here:
  # /opt/supermarket/embedded/lib/ruby/2.1.0/net/http.rb:920:in `connect': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)
  #
  # Tried:
  #
  # * Setting the SSL_CERT_FILE environment variable to the cacert.pem dependency
  #   in that softawre
  # * Creating .berkshelf/config.json in the cookbook with ssl verify false
  #
  # Haven't tried outside of vagrant/kitchen, so it could be specific to one
  # of those.
  #
  # It's failing on the "enterprise" dependency in
  # cookbooks/omnibus-supermarket/Berksfile, which is open source on GitHub.
  # Same failure happens if I use http:// or git://.
  #
  # We weren't seeing this when we were using berkshelf2, but we switched to
  # 3 because we're using 3 in the cookbook itself, and the file size issues are
  # much better now, and 2 is deprecated.
  #
  #command "berks vendor --path=#{cookbooks_path}", env: env
  #
  # Do this instead for now, so the directory is there:
  mkdir cookbooks_path

  block do
    open("#{cookbooks_path}/dna.json", "w") do |file|
      file.write JSON.fast_generate(run_list: ['recipe[omnibus-supermarket::default]'])
    end

    open("#{cookbooks_path}/show-config.json", "w") do |file|
      file.write JSON.fast_generate(
        run_list: ['recipe[omnibus-supermarket::show_config]']
      )
    end

    open("#{cookbooks_path}/solo.rb", "w") do |file|
      file.write <<-EOH.gsub(/^ {8}/, '')
        cookbook_path   "#{cookbooks_path}"
        file_cache_path "#{cookbooks_path}/cache"
        verbose_logging true
        ssl_verify_mode :verify_peer
      EOH
    end
  end
end
