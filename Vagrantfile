# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box     = 'opscode-ubuntu-12.04'
  config.vm.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'

  config.omnibus.chef_version = '11.6.2'

  # config.vm.network :private_network, ip: '172.0.1.50'
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.synced_folder './', '/supermarket'
  config.vm.synced_folder './', '/vagrant', disabled: true

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '4096']
    vb.customize ['modifyvm', :id, '--cpus', '4']
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'deploy/cookbooks'
    chef.roles_path     = 'deploy/roles'
    chef.data_bags_path = 'deploy/data_bags'

    chef.formatter = 'doc'
    chef.log_level = :warn

    chef.run_list = [
      'recipe[supermarket::default]'
    ]
  end
end
