source 'https://supermarket.getchef.com'

# The apt cookbook is required to bring the apt cache up-to-date on Ubuntu
# systems, since the cache can become stale on older boxes.
cookbook 'apt', '~> 2.0'

# Needs to be resolved in order to load the omnibus-supermarket cookbook
cookbook 'enterprise',
         git: 'https://github.com/opscode-cookbooks/enterprise-chef-common.git',
         tag: '0.4.5'

cookbook 'omnibus'
cookbook 'omnibus-supermarket', path: './cookbooks/omnibus-supermarket'

cookbook 'yum-epel', '~> 0.6'
