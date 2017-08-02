name 'supermarket-deploy'
maintainer 'Chef Software Inc Engineering'
maintainer_email 'engineering@chef.io'
license 'all_rights'
description 'Installs/Configures supermarket in ACC'
long_description 'Installs/Configures supermarket in ACC'
version '0.1.3'

chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'cd-deploy'
