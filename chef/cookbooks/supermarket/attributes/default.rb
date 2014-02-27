#
# Author:: Tristan O'Neil (<tristanoneil@gmail.com>)
# Attributes:: supermarket
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

default['postgres']['user'] = 'supermarket'
default['postgres']['database'] = 'supermarket_production'
default['postgres']['auth_method'] = 'peer'

default['redis']['maxmemory'] = '64mb'

default['supermarket']['cla_signature_notification_email'] = 'notifications@example.com'
default['supermarket']['from_email'] = 'donotreply@example.com'
default['supermarket']['home'] = '/srv/supermarket'
default['supermarket']['host'] = 'supermarket.getchef.com'
default['supermarket']['sidekiq']['concurrency'] = '25'
