#########################################################################
# Docker
#########################################################################
include_recipe 'chef-apt-docker::default'

package "docker-engine"

execute 'install docker-compose' do
  command <<-EOH
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOH
end

# Ensure the `dbuild` user is part of the `docker` group so they can
# connect to the Docker daemon
execute "usermod -aG docker #{node['delivery_builder']['build_user']}"

