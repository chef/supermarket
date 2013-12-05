#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: node
#
# Copyright 2013 Chef, Inc.
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

# NodeJS is required because of the asset pipeline needs a valud JS runtime

include_recipe 'supermarket::_apt'

package 'python-software-properties'
package 'python'
package 'g++'
package 'make'

execute 'add-apt-repository[ppa:chris-lea]' do
  command 'add-apt-repository -y ppa:chris-lea/node.js'
  notifies :run, 'execute[apt-get update]', :immediately
  not_if 'test -f /etc/apt/sources.list.d/chris-lea-node_js-precise.list'
end

package 'nodejs'
