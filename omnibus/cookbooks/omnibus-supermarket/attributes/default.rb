# # Supermarket configuration
#
# Attributes here will be applied to configure the application and the services
# it uses.
#
# Most of the attributes in this file are things you will not need to ever
# touch, but they are here in case you need them.
#
# A `supermarket-ctl reconfigure` should pick up any changes made here.
#
# If /etc/supermarket/supermarket.json exists, its attributes will be loaded
# after these, so if you have that file with the contents:
#
#     { "redis": { "enable": false } }
#
# for example, it will set the node['supermarket']['redis'] attribute to false.

# ## Common Use Cases
#
# These are examples of things you may want to do, depending on how you set up
# the application to run.
#
# ### Chef Identity
#
# You will have to set this up in order to log into Supermarket and upload
# cookbooks with your Chef server keys.
#
# See the "Chef OAuth2 Settings" section below
#
# ### Using an external Postgres database
#
# Disable the provided Postgres instance and connect to your own:
#
# default['supermarket']['postgresql']['enable'] = false
# default['supermarket']['database']['user'] = 'my_db_user_name'
# default['supermarket']['database']['name'] = 'my_db_name''
# default['supermarket']['database']['host'] = 'my.db.server.address'
# default['supermarket']['database']['port'] = 5432
#
# ### Using an external Redis server
#
# Disable the provided Redis server and use on reachable on your network:
#
# default['supermarket']['redis']['enable'] = false
# default['supermarket']['redis_url'] = 'redis://my.redis.host:6379/0/mydbname
#
# ### Bring your on SSL certificate
#
# If a key and certificate are not provided, a self-signed certificate will be
# generated. To use your own, provide the paths to them and ensure SSL is
# enabled in Nginx:
#
# default['supermarket']['nginx']['force_ssl'] = true
# default['supermarket']['ssl']['certificate'] = '/path/to/my.crt'
# default['supermarket']['ssl']['certificate_key'] = '/path/to/my.key'

# ## Top-level attributes
#
# These are used by the other items below. More app-specific top-level
# attributes are further down in this file.

# The fully qualified domain name. Will use the node's fqdn if nothing is
# specified.
default['supermarket']['fqdn'] = (node['fqdn'] || node['hostname']).downcase

# The URL for the Chef server. Used with the "Chef OAuth2 Settings" and
# "Chef URL Settings" below. If this is not set, authentication and some of the
# links in the application will not work.
default['supermarket']['chef_server_url'] = nil

default['supermarket']['config_directory'] = '/etc/supermarket'
default['supermarket']['install_directory'] = '/opt/supermarket'
default['supermarket']['app_directory'] = "#{node['supermarket']['install_directory']}/embedded/service/supermarket"
default['supermarket']['log_directory'] = '/var/log/supermarket'
default['supermarket']['var_directory'] = '/var/opt/supermarket'
default['supermarket']['data_directory'] = '/var/opt/supermarket/data'
default['supermarket']['user'] = 'supermarket'
default['supermarket']['group'] = 'supermarket'

# ## Enterprise
#
# The "enterprise" cookbook provides recipes and resources we can use for this
# app.

default['enterprise']['name'] = 'supermarket'

# Enterprise uses install_path internally, but we use install_directory because
# it's more consistent. Alias it here so both work.
default['supermarket']['install_path'] = node['supermarket']['install_directory']

# An identifier used in /etc/inittab (default is 'SV'). Needs to be a unique
# (for the file) sequence of 1-4 characters.
default['supermarket']['sysvinit_id'] = 'SUP'

# ## Nginx

# These attributes control Supermarket-specific portions of the Nginx
# configuration and the virtual host for the Supermarket Rails app.
default['supermarket']['nginx']['enable'] = true
default['supermarket']['nginx']['force_ssl'] = true
default['supermarket']['nginx']['non_ssl_port'] = 80
default['supermarket']['nginx']['ssl_port'] = 443
default['supermarket']['nginx']['directory'] = "#{node['supermarket']['var_directory']}/nginx/etc"
default['supermarket']['nginx']['log_directory'] = "#{node['supermarket']['log_directory']}/nginx"
default['supermarket']['nginx']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['nginx']['log_rotation']['num_to_keep'] = 10
default['supermarket']['nginx']['log_x_forwarded_for'] = false

# Redirect to the FQDN
default['supermarket']['nginx']['redirect_to_canonical'] = true

# Controls nginx caching, used to cache some endpoints
default['supermarket']['nginx']['cache']['enable'] = false
default['supermarket']['nginx']['cache']['directory'] = "#{node['supermarket']['var_directory']}/nginx//cache"

# These attributes control the main nginx.conf, including the events and http
# contexts.
#
# These will be copied to the top-level nginx namespace and used in a
# template from the community nginx cookbook
# (https://github.com/miketheman/nginx/blob/master/templates/default/nginx.conf.erb)
default['supermarket']['nginx']['user'] = node['supermarket']['user']
default['supermarket']['nginx']['group'] = node['supermarket']['group']
default['supermarket']['nginx']['dir'] = node['supermarket']['nginx']['directory']
default['supermarket']['nginx']['log_dir'] = node['supermarket']['nginx']['log_directory']
default['supermarket']['nginx']['pid'] = "#{node['supermarket']['nginx']['directory']}/nginx.pid"
default['supermarket']['nginx']['daemon_disable'] = true
default['supermarket']['nginx']['gzip'] = 'on'
default['supermarket']['nginx']['gzip_static'] = 'off'
default['supermarket']['nginx']['gzip_http_version'] = '1.0'
default['supermarket']['nginx']['gzip_comp_level'] = '2'
default['supermarket']['nginx']['gzip_proxied'] = 'any'
default['supermarket']['nginx']['gzip_vary'] = 'off'
default['supermarket']['nginx']['gzip_buffers'] = nil
default['supermarket']['nginx']['gzip_types'] = %w(
  text/plain
  text/css
  application/x-javascript
  text/xml
  application/xml
  application/rss+xml
  application/atom+xml
  text/javascript
  application/javascript
  application/json
)
default['supermarket']['nginx']['gzip_min_length'] = 1000
default['supermarket']['nginx']['gzip_disable'] = 'MSIE [1-6]\.'
default['supermarket']['nginx']['keepalive'] = 'on'
default['supermarket']['nginx']['keepalive_timeout'] = 65
default['supermarket']['nginx']['worker_processes'] = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['supermarket']['nginx']['worker_connections'] = 1024
default['supermarket']['nginx']['worker_rlimit_nofile'] = nil
default['supermarket']['nginx']['multi_accept'] = false
default['supermarket']['nginx']['event'] = nil
default['supermarket']['nginx']['server_tokens'] = nil
default['supermarket']['nginx']['server_names_hash_bucket_size'] = 64
default['supermarket']['nginx']['sendfile'] = 'on'
default['supermarket']['nginx']['access_log_options'] = nil
default['supermarket']['nginx']['error_log_options'] = nil
default['supermarket']['nginx']['disable_access_log'] = false
default['supermarket']['nginx']['default_site_enabled'] = false
default['supermarket']['nginx']['types_hash_max_size'] = 2048
default['supermarket']['nginx']['types_hash_bucket_size'] = 64
default['supermarket']['nginx']['proxy_read_timeout'] = nil
default['supermarket']['nginx']['client_body_buffer_size'] = nil
default['supermarket']['nginx']['client_max_body_size'] = '250m'
default['supermarket']['nginx']['default']['modules'] = []

# ## Postgres

default['supermarket']['postgresql']['enable'] = true
default['supermarket']['postgresql']['username'] = node['supermarket']['user']
default['supermarket']['postgresql']['data_directory'] = "#{node['supermarket']['var_directory']}/postgresql/9.3/data"

# ### Logs
default['supermarket']['postgresql']['log_directory'] = "#{node['supermarket']['log_directory']}/postgresql"
default['supermarket']['postgresql']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['postgresql']['log_rotation']['num_to_keep'] = 10

# ### DB settings
default['supermarket']['postgresql']['checkpoint_completion_target'] = 0.5
default['supermarket']['postgresql']['checkpoint_segments'] = 3
default['supermarket']['postgresql']['checkpoint_timeout'] = '5min'
default['supermarket']['postgresql']['checkpoint_warning'] = '30s'
default['supermarket']['postgresql']['effective_cache_size'] = '128MB'
default['supermarket']['postgresql']['listen_address'] = '127.0.0.1'
default['supermarket']['postgresql']['max_connections'] = 350
default['supermarket']['postgresql']['md5_auth_cidr_addresses'] = ['127.0.0.1/32', '::1/128']
default['supermarket']['postgresql']['port'] = 15432
default['supermarket']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / 1024}MB"
default['supermarket']['postgresql']['shmmax'] = 17179869184
default['supermarket']['postgresql']['shmall'] = 4194304
default['supermarket']['postgresql']['work_mem'] = '8MB'

# ## Rails
#
# The Rails app for Supermarket
default['supermarket']['rails']['enable'] = true
default['supermarket']['rails']['port'] = 13000
default['supermarket']['rails']['log_directory'] = "#{node['supermarket']['log_directory']}/rails"
default['supermarket']['rails']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['rails']['log_rotation']['num_to_keep'] = 10

# ## Redis

default['supermarket']['redis']['enable'] = true
default['supermarket']['redis']['bind'] = '127.0.0.1'
default['supermarket']['redis']['directory'] = "#{node['supermarket']['var_directory']}/redis"
default['supermarket']['redis']['log_directory'] = "#{node['supermarket']['log_directory']}/redis"
default['supermarket']['redis']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['redis']['log_rotation']['num_to_keep'] = 10
default['supermarket']['redis']['port'] = 16379

# ## Runit

# This is missing from the enterprise cookbook
# see (https://github.com/chef-cookbooks/enterprise-chef-common/pull/17)
#
# Will be copied to the root node.runit namespace.
default['supermarket']['runit']['svlogd_bin'] = "#{node['supermarket']['install_directory']}/embedded/bin/svlogd"

# ## Sidekiq
#
# Used for background jobs

default['supermarket']['sidekiq']['enable'] = true
default['supermarket']['sidekiq']['concurrency'] = 25
default['supermarket']['sidekiq']['log_directory'] = "#{node['supermarket']['log_directory']}/sidekiq"
default['supermarket']['sidekiq']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['sidekiq']['log_rotation']['num_to_keep'] = 10
default['supermarket']['sidekiq']['timeout'] = 30

# ## SSL

default['supermarket']['ssl']['directory'] = '/var/opt/supermarket/ssl'

# Paths to the SSL certificate and key files. If these are not provided we will
# attempt to generate a self-signed certificate and use that instead.
default['supermarket']['ssl']['enabled'] = true
default['supermarket']['ssl']['certificate'] = nil
default['supermarket']['ssl']['certificate_key'] = nil
default['supermarket']['ssl']['ssl_dhparam'] = nil

# These are used in creating a self-signed cert if you haven't brought your own.
default['supermarket']['ssl']['country_name'] = 'US'
default['supermarket']['ssl']['state_name'] = 'WA'
default['supermarket']['ssl']['locality_name'] = 'Seattle'
default['supermarket']['ssl']['company_name'] = 'My Supermarket'
default['supermarket']['ssl']['organizational_unit_name'] = 'Operations'
default['supermarket']['ssl']['email_address'] = 'you@example.com'

# ### Cipher settings
#
# Based off of the Mozilla recommended cipher suite
# https://wiki.mozilla.org/Security/Server_Side_TLS#Recommended_Ciphersuite
#
# SSLV3 was removed because of the poodle attack. (https://www.openssl.org/~bodo/ssl-poodle.pdf)
#
# If your infrastructure still has requirements for the vulnerable/venerable SSLV3, you can add
# "SSLv3" to the below line.
default['supermarket']['ssl']['ciphers'] = 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA'
default['supermarket']['ssl']['fips_ciphers'] = 'FIPS@STRENGTH:!aNULL:!eNULL'
default['supermarket']['ssl']['protocols'] = 'TLSv1 TLSv1.1 TLSv1.2'
default['supermarket']['ssl']['session_cache'] = 'shared:SSL:4m'
default['supermarket']['ssl']['session_timeout'] = '5m'

# ## Unicorn
#
# Settings for main Rails app Unicorn application server. These attributes are
# used with the template from the community Unicorn cookbook:
# https://github.com/chef-cookbooks/unicorn/blob/master/templates/default/unicorn.rb.erb
#
# Full explanation of all options can be found at
# http://unicorn.bogomips.org/Unicorn/Configurator.html

default['supermarket']['unicorn']['name'] = 'supermarket'
default['supermarket']['unicorn']['copy_on_write'] = true
default['supermarket']['unicorn']['enable_stats'] = false
default['supermarket']['unicorn']['forked_user'] = node['supermarket']['user']
default['supermarket']['unicorn']['forked_group'] = node['supermarket']['group']
default['supermarket']['unicorn']['listen'] = ["127.0.0.1:#{node['supermarket']['rails']['port']}"]
default['supermarket']['unicorn']['pid'] = "#{node['supermarket']['var_directory']}/rails/run/unicorn.pid"
default['supermarket']['unicorn']['preload_app'] = true
default['supermarket']['unicorn']['worker_timeout'] = 15
default['supermarket']['unicorn']['worker_processes'] = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1

# These are not used, but you can set them if needed
default['supermarket']['unicorn']['before_exec'] = nil
default['supermarket']['unicorn']['stderr_path'] = nil
default['supermarket']['unicorn']['stdout_path'] = nil
default['supermarket']['unicorn']['unicorn_command_line'] = nil
default['supermarket']['unicorn']['working_directory'] = nil

# These are defined a recipe to be specific things we need that you
# could change here, but probably should not.
default['supermarket']['unicorn']['before_fork'] = nil
default['supermarket']['unicorn']['after_fork'] = nil

# ## Database

default['supermarket']['database']['user'] = node['supermarket']['postgresql']['username']
default['supermarket']['database']['name'] = 'supermarket'
default['supermarket']['database']['host'] = node['supermarket']['postgresql']['listen_address']
default['supermarket']['database']['port'] = node['supermarket']['postgresql']['port']
default['supermarket']['database']['pool'] = node['supermarket']['sidekiq']['concurrency']
default['supermarket']['database']['extensions'] = { 'plpgsql' => true, 'pg_trgm' => true }

# ## App-specific top-level attributes
#
# These are used by Rails and Sidekiq. Most will be exported directly to
# environment variables to be used by the app.
#
# Items that are set to nil here and also set in the development environment
# configuration (https://github.com/chef/supermarket/blob/master/.env) will
# use the value from the development environment. Set them to something other
# than nil to change them.

default['supermarket']['fieri_url'] = 'http://localhost:13000/fieri/jobs'
default['supermarket']['fieri_supermarket_endpoint'] = 'https://localhost:13000'
default['supermarket']['fieri_key'] = nil
default['supermarket']['from_email'] = nil
default['supermarket']['github_access_token'] = nil
default['supermarket']['github_key'] = nil
default['supermarket']['github_secret'] = nil
default['supermarket']['google_analytics_id'] = nil
default['supermarket']['segment_write_key'] = nil
default['supermarket']['newrelic_agent_enabled'] = 'false'
default['supermarket']['newrelic_app_name'] = nil
default['supermarket']['newrelic_license_key'] = nil
default['supermarket']['datadog_tracer_enabled'] = 'false'
default['supermarket']['datadog_app_name'] = nil
default['supermarket']['port'] = node['supermarket']['nginx']['force_ssl'] ? node['supermarket']['nginx']['ssl_port'] : node['supermarket']['non_ssl_port']
default['supermarket']['protocol'] = node['supermarket']['nginx']['force_ssl'] ? 'https' : 'http'
default['supermarket']['pubsubhubbub_callback_url'] = nil
default['supermarket']['pubsubhubbub_secret'] = nil
default['supermarket']['redis_url'] = 'redis://127.0.0.1:16379/0/supermarket'
default['supermarket']['redis_jobq_url'] = nil
default['supermarket']['sentry_url'] = nil
default['supermarket']['api_item_limit'] = 100
default['supermarket']['rails_log_to_stdout'] = true
default['supermarket']['fips_enabled'] = nil

# Allow owners to remove their cookbooks, cookbook versions, or tools.
# Added as a step towards implementing RFC072 Artifact Yanking
# https://github.com/chef/chef-rfc/blob/f8250a4746d2df530b605ecfaa2dc5ae9b7dc7ff/rfc072-artifact-yanking.md
# recommend false; set to true as default for backward compatibility
default['supermarket']['owners_can_remove_artifacts'] = true

# ### Chef URL Settings
#
# URLs for various links used within Supermarket
#
# These have defaults in the app based on the chef_server_url along the lines of the interpolations below.
# Override if you need to set these URLs to targets other than the configured chef_server_url.
#
# default['supermarket']['chef_identity_url'] = "#{node['supermarket']['chef_server_url']}/id"
# default['supermarket']['chef_manage_url'] = node['supermarket']['chef_server_url']
# default['supermarket']['chef_profile_url'] = node['supermarket']['chef_server_url']
# default['supermarket']['chef_sign_up_url'] = "#{node['supermarket']['chef_server_url']}/signup?ref=community"

# URLs for Chef Software, Inc. sites. Most of these have defaults set in
# Supermarket already, but you can customize them here to your liking
default['supermarket']['chef_domain'] = 'chef.io'
default['supermarket']['chef_www_url'] = 'https://www.chef.io'
#
# These have defaults in the app based on the chef_domain along the lines of the interpolations below.
# Override if you need to set these URLs to targets other than the configured chef_domain.
#
# default['supermarket']['chef_blog_url'] = "https://www.#{node['supermarket']['chef_domain']}/blog"
# default['supermarket']['chef_docs_url'] = "https://docs.#{node['supermarket']['chef_domain']}"
# default['supermarket']['chef_downloads_url'] = "https://downloads.#{node['supermarket']['chef_domain']}"
# default['supermarket']['learn_chef_url'] = "https://learn.#{node['supermarket']['chef_domain']}"

# ### Chef OAuth2 Settings
#
# These settings configure the service to talk to a Chef identity service.
#
# An Application must be created on the Chef server's identity service to do
# this. With the following in /etc/opscode/chef-server.rb:
#
#     oc_id['applications'] = { 'my_supermarket' => { 'redirect_uri' => 'https://my.supermarket.server.fqdn/auth/chef_oauth2/callback' } }
#
# Run `chef-server-ctl reconfigure`, then these values should available in
# /etc/opscode/oc-id-applications/my_supermarket.json.
#
# The chef_oauth2_url should be the root URL of your Chef server.
#
# If you are using a self-signed certificate on your Chef server without a
# properly configured certificate authority, chef_oauth2_verify_ssl must be
# false.
default['supermarket']['chef_oauth2_app_id'] = nil
default['supermarket']['chef_oauth2_secret'] = nil
default['supermarket']['chef_oauth2_url'] = nil
default['supermarket']['chef_oauth2_verify_ssl'] = true

# ### Features
#
# These control the feature flags that turn features on and off.
#
# Available features are:
#
# * announcement: Display the Supermarket initial launch announcement banner
#   (this will most likely be of no use to you, but could be made a
#   configurable thing in the future.)
# * collaborator_groups: Enable collaborator groups, allowing management of collaborators through groups
# * fieri: Use the fieri service to report on cookbook quality (requires
#   fieri_url, fieri_supermarket_endpoint, and fieri_key to be set.)
# * github: Enable GitHub integration, used with CLA signing
# * gravatar: Enable Gravatar integration, used for user avatars
# * tools: Enable the tools section
default['supermarket']['features'] = 'tools, gravatar'

# ### Air Gapped Settings
# This controls whether your Supermarket will reach out to 3rd party services like certain fonts
# and Google Analytics.
default['supermarket']['air_gapped'] = 'false'

# ### robots.txt Settings
#
# These control the "Allow" and "Disallow" paths in /robots.txt. See
# http://www.robotstxt.org/robotstxt.html for more information. Only a single
# line for each item is supported. If a value is nil, the line will not be
# present in the file.
default['supermarket']['robots_allow'] = '/'
default['supermarket']['robots_disallow'] = nil

# ### S3 Settings
#
# If these are not set, uploaded cookbooks will be stored on the local
# filesystem (this means that running multiple application servers will require
# some kind of shared storage, which is not provided.)

# #### Required S3

# If these are set, cookbooks will be uploaded to the to the given S3 bucket.
# The default is to rely on an IAM role with access to the bucket be attached to
# the compute resources running Supermarket.
default['supermarket']['s3_bucket'] = nil
default['supermarket']['s3_region'] = nil

# #### Optional S3

# S3 Server Side Encryption can be enabled by setting to AES256
default['supermarket']['s3_encryption'] = nil

# A cdn_url can be used for an alias if the S3 bucket is behind a CDN like CloudFront.
default['supermarket']['cdn_url'] = nil

# If set then supermarket will apply an object-level private ACL. For this to work,
# the relevant IAM and bucket policies will need to allow PutObjectACL permissions.
# Note: if this is not set, and "Block all public access" is on for the bucket then Chef
# Supermarket will be unable to update cookbooks.
# default['supermarket']['s3_private_objects'] = nil

# If using IAM user credentials for bucket access, set these.
default['supermarket']['s3_access_key_id'] = nil
default['supermarket']['s3_secret_access_key'] = nil

# By default, Supermarket will use domain style S3 urls that look like this:
#
#   bucketname.s3.amazonaws.com
#
# This style of url will work across all regions.
#
# If this is set as ':s3_path_url', the S3 urls will look like this
# s3.amazonaws.com/bucketname.
# This will only work if the S3 bucket is in N. Virginia.
# If your S3 bucket name contains any periods "." - i.e. "my.bucket.name",
# you must use the path style url and your S3 bucket must be in N. Virginia
default['supermarket']['s3_domain_style'] = ':s3_domain_url'

# ### SMTP Settings
#
# If none of these are set, the :sendmail delivery method will be used. Using
# the sendmail delivery method requires that a working mail transfer agent
# (usually set up with a relay host) be configured on this machine.
#
# SMTP will use the 'plain' authentication method.
default['supermarket']['smtp_address'] = nil
default['supermarket']['smtp_password'] = nil
default['supermarket']['smtp_port'] = nil
default['supermarket']['smtp_user_name'] = nil

# ### StatsD Settings
#
# If these are present, metrics can be reported to a StatsD server.
default['supermarket']['statsd_url'] = nil
default['supermarket']['statsd_port'] = nil
