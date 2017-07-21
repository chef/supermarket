name 'build_cookbook'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
version '0.2.4'

gem 'aws-sdk'
gem 'json', '~> 1.8'
gem 'chef-sugar'

chef_version '>= 12.19'

depends 'delivery-truck'
depends 'expeditor-build'
