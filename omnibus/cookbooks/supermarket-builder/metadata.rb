name             'supermarket-builder'
maintainer       'Chef Supermarket Team'
maintainer_email 'supermarket@chef.io'
license          'Apache-2.0'
description      'Builds a Supermarket omnibus package for development/testing'
version          '1.0.0'

depends          'yum-epel'
depends          'omnibus'

chef_version     '>= 13.0'
