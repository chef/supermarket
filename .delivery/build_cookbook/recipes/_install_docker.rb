#########################################################################
# Docker
#########################################################################
include_recipe 'chef-apt-docker::default'

package "docker-engine"

remote_file '/usr/local/bin/docker-compose' do
  source 'https://github.com/docker/compose/releases/download/1.8.0/docker-compose-Linux-x86_64'
  checksum 'ebc6ab9ed9c971af7efec074cff7752593559496d0d5f7afb6bfd0e0310961ff'
  owner 'root'
  group 'docker'
  mode  '0755'
end

# Ensure the `dbuild` user is part of the `docker` group so they can
# connect to the Docker daemon
execute "usermod -aG docker #{node['delivery_builder']['build_user']}"
