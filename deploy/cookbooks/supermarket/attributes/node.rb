default['supermarket']['node']['version'] = '0.10.21'
default['supermarket']['node']['source_url'] = "http://nodejs.org/dist/v#{node['supermarket']['node']['version']}/node-v#{node['supermarket']['node']['version']}.tar.gz"
default['supermarket']['node']['src_dir']  = '/src'

default['supermarket']['node']['prefix'] = '/usr/local'
