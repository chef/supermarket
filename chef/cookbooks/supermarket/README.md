# Supermarket

This cookbook deploys the [Supermarket application](https://github.com/opscode/supermarket).

## About

This cookbook is split up into three different roles. Web, redis and database if you plan on running Supermarket
on a single node you'll want to add all three of these roles to the run list. By default with all three roles applied
to a single node Supermarket relies on Postgres peer authentication so there is no database password set.

In the scenario that you need to connect to another Postgres database server you may override Supermarket's database
configuration within the app/supermarket.json databag to configure a host, username and password.

In the scenario that you need to connect to another Redis server you may override Supermarket's Sidekiq configuration
within the app/supermarket.json databag.

# License and Authors

- Author: Brett Chalupa (<brett@gofullstack.com>)
- Author: Brian Cobb (<brian@gofullstack.com>)
- Author: Seth Vargo (<sethvargo@gmail.com>)
- Author: Tristan O'Neil (<tristanoneil@gmail.com>)
- Author: Joshua Timberman (<joshua@getchef.com>)
- Author: Gleb M Borisov (<borisov.gleb@gmail.com>)

- Copyright (C) 2014, Chef Software, Inc. (<legal@getchef.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
