name 'supermarket-deploy'
maintainer 'Chef Software Inc Engineering'
maintainer_email 'engineering@chef.io'
license 'all_rights'
description 'Installs/Configures supermarket in ACC'
long_description 'Installs/Configures supermarket in ACC'
version '0.0.1'

chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'chef-ingredient'

# TODO: extract common libraries to cd-deploy
# depends 'cd-deploy'
