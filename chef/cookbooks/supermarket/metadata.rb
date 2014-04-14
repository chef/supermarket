name 'supermarket'
version '1.2.2'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@getchef.com'
license 'Apache v2.0'
description 'Stands up the Supermarket application stack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

supports 'ubuntu'

recipe 'supermarket::default',
       'Installs Supermarket and all dependencies for production'

recipe 'supermarket::vagrant',
       'Installs Supermarket and all dependencies for development'

provides 'service[nginx]'
provides 'service[postgres]'
provides 'service[redis-server]'
provides 'service[unicorn]'

grouping 'postgres', :title => 'PostgreSQL options'

attribute 'postgres/user',
          :display_name => 'PostgreSQL username',
          :type         => 'string',
          :default      => 'supermarket'

attribute 'postgres/database',
          :display_name => 'PostgreSQL database name',
          :type         => 'string',
          :default      => 'supermarket_production'

attribute 'postgres/auth_method',
          :display_name => 'PostgreSQL authentication method',
          :type         => 'string',
          :default      => 'peer'

grouping 'redis', :title => 'Redis server options'

attribute 'redis/maxmemory',
          :display_name => 'Maximum memory used by redis server',
          :type         => 'string',
          :default      => '64mb'

grouping 'supermarket', :title => 'Supermarket options'

attribute 'supermarket/cla_signature_notification_email',
          :display_name => 'E-mail address used to notify about CLA signs',
          :type         => 'string',
          :required     => 'recommended'

attribute 'supermarket/from_email',
          :display_name => 'E-mail address used to send e-mails from',
          :type         => 'string',
          :required     => 'recommended'

attribute 'supermarket/home',
          :display_name => 'Directory to deploy Supermarket application',
          :type         => 'string',
          :default      => '/srv/supermarket'

attribute 'supermarket/host',
          :display_name => 'Hostname of Supermarket application',
          :type         => 'string',
          :default      => 'supermarket.getchef.com'

attribute 'supermarket/sidekiq/concurrency',
          :display_name => 'Number of concurrent jobs executed by sidekiq',
          :type         => 'string',
          :default      => '25'
