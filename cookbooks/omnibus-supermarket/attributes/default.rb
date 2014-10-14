# Supermarket configuration
#
# Attributes here will be applied to configure the application.

# Top-level attributes
######################
#
# These are used by the other items below. More app-specific top-level
# attributes are further down in this file.

# The fully qualified domain name. Will use the node's fqdn if nothing is
# specified.
default['supermarket']['fqdn'] = node['fqdn']
default['supermarket']['config_directory'] = '/etc/supermarket'
default['supermarket']['install_directory'] = '/opt/supermarket'
default['supermarket']['app_directory'] = "#{node['supermarket']['install_directory']}/embedded/service/supermarket"
default['supermarket']['log_directory'] = '/var/log/supermarket'
default['supermarket']['var_directory'] = '/var/opt/supermarket'
default['supermarket']['user'] = 'supermarket'
default['supermarket']['group'] = 'supermarket'

# Enterprise
############
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

# Nginx
#######

default['supermarket']['nginx']['enable'] = true
default['supermarket']['nginx']['directory'] = "#{node['supermarket']['var_directory']}/nginx"
default['supermarket']['nginx']['log_directory'] = "#{node['supermarket']['log_directory']}/nginx"
default['supermarket']['nginx']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['nginx']['log_rotation']['num_to_keep'] = 10

# These attributes control the main nginx.conf, including the events and http
# contexts. Note that they are not scoped to 'supermarket', like most things
# here, because we're using the template from the community nginx cookbook
# (https://github.com/miketheman/nginx/blob/master/templates/default/nginx.conf.erb)
default['nginx']['user'] = node['supermarket']['user']
default['nginx']['group'] = node['supermarket']['group']
default['nginx']['dir'] = node['supermarket']['nginx']['directory']
default['nginx']['log_dir'] = node['supermarket']['nginx']['log_directory']
default['nginx']['pid'] = "#{node['supermarket']['nginx']['directory']}/nginx.pid"
default['nginx']['daemon_disable'] = true
default['nginx']['gzip'] = 'on'
default['nginx']['gzip_static'] = 'off'
default['nginx']['gzip_http_version'] = '1.0'
default['nginx']['gzip_comp_level'] = '2'
default['nginx']['gzip_proxied'] = 'any'
default['nginx']['gzip_vary'] = 'off'
default['nginx']['gzip_buffers'] = nil
default['nginx']['gzip_types'] = %w(
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
default['nginx']['gzip_min_length'] = 1000
default['nginx']['gzip_disable'] = 'MSIE [1-6]\.'

default['nginx']['keepalive'] = 'on'
default['nginx']['keepalive_timeout'] = 65
default['nginx']['worker_processes'] = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['nginx']['worker_connections'] = 1024
default['nginx']['worker_rlimit_nofile'] = nil
default['nginx']['multi_accept'] = false
default['nginx']['event'] = nil
default['nginx']['server_tokens'] = nil
default['nginx']['server_names_hash_bucket_size'] = 64
default['nginx']['sendfile'] = 'on'
default['nginx']['access_log_options'] = nil
default['nginx']['error_log_options'] = nil
default['nginx']['disable_access_log'] = false
default['nginx']['default_site_enabled'] = false
default['nginx']['types_hash_max_size'] = 2048
default['nginx']['types_hash_bucket_size'] = 64

default['nginx']['proxy_read_timeout'] = nil
default['nginx']['client_body_buffer_size'] = nil
default['nginx']['client_max_body_size'] = '250m'
default['nginx']['default']['modules'] = []

# Postgres
##########

default['supermarket']['postgresql']['enable'] = true
default['supermarket']['postgresql']['username'] = node['supermarket']['user']
default['supermarket']['postgresql']['data_directory'] = "#{node['supermarket']['var_directory']}/postgresql/9.3/data"
# Logs
default['supermarket']['postgresql']['log_directory'] = "#{node['supermarket']['log_directory']}/postgresql"
default['supermarket']['postgresql']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['postgresql']['log_rotation']['num_to_keep'] = 10
# DB settings
default['supermarket']['postgresql']['checkpoint_completion_target'] = 0.5
default['supermarket']['postgresql']['checkpoint_segments'] = 3
default['supermarket']['postgresql']['checkpoint_timeout'] = '5min'
default['supermarket']['postgresql']['checkpoint_warning'] = '30s'
default['supermarket']['postgresql']['effective_cache_size'] = '128MB'
default['supermarket']['postgresql']['listen_address'] = '127.0.0.1'
default['supermarket']['postgresql']['max_connections'] = 350
default['supermarket']['postgresql']['md5_auth_cidr_addresses'] = ['127.0.0.1/32', '::1/128']
default['supermarket']['postgresql']['port'] = 15432
default['supermarket']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
default['supermarket']['postgresql']['shmmax'] = 17179869184
default['supermarket']['postgresql']['shmall'] = 4194304
default['supermarket']['postgresql']['work_mem'] = "8MB"

# Redis
#######

default['supermarket']['redis']['enable'] = true
default['supermarket']['redis']['bind'] = '127.0.0.1'
default['supermarket']['redis']['directory'] = "#{node['supermarket']['var_directory']}/redis"
default['supermarket']['redis']['log_directory'] = "#{node['supermarket']['log_directory']}/redis"
default['supermarket']['redis']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['redis']['log_rotation']['num_to_keep'] = 10
default['supermarket']['redis']['port'] = 16379

# Runit
#######

# This is missing from the enterprise cookbook
# see (https://github.com/opscode-cookbooks/enterprise-chef-common/pull/17)
default['runit']['svlogd_bin'] = "#{node['supermarket']['install_directory']}/embedded/bin/svlogd"

# SSL
#####

default['supermarket']['ssl']['directory'] = '/var/opt/supermarket/ssl'

# This shouldn't be changed, but can be overriden in tests
default['supermarket']['ssl']['openssl_bin'] = "#{node['supermarket']['install_directory']}/embedded/bin/openssl"

# Paths to the SSL certificate and key files. If these are not provided we will
# attempt to generate a self-signed certificate and use that instead.
default['supermarket']['ssl']['certificate'] = nil
default['supermarket']['ssl']['certificate_key'] = nil

# These are used in creating a self-signed cert if you haven't brought your own.
default['supermarket']['ssl']['country_name'] = "US"
default['supermarket']['ssl']['state_name'] = "WA"
default['supermarket']['ssl']['locality_name'] = "Seattle"
default['supermarket']['ssl']['company_name'] = "My Supermarket"
default['supermarket']['ssl']['organizational_unit_name'] = "Operations"
default['supermarket']['ssl']['email_address'] = "you@example.com"

# Database
##########

default['supermarket']['database']['user'] = node['supermarket']['postgresql']['username']
default['supermarket']['database']['name'] = 'supermarket'
default['supermarket']['database']['host'] = node['supermarket']['postgresql']['listen_address']
default['supermarket']['database']['port'] = node['supermarket']['postgresql']['port']

# App-specific top-level attributes
###################################
#
# These are used by Rails and Sidekiq. Most will be exported directly to
# environment variables to be used by the app.
default['supermarket']['redis_url'] = "redis://#{node['supermarket']['redis']['bind']}:#{node['supermarket']['redis']['port']}/0/supermarket"
