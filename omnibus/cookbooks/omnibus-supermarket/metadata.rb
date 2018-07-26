name             'omnibus-supermarket'
maintainer       'Chef Supermarket Team'
maintainer_email 'supermarket@chef.io'
license          'Apache-2.0'
description      'Installs/Configures supermarket in an Omnibus installation'
long_description 'Installs/Configures supermarket in an Omnibus installation'
version          '1.1.1'

chef_version     '>= 14.0'

depends          'enterprise'
depends          'runit', '>= 3.0.3'
depends          'unicorn'
