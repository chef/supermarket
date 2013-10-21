# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "opscode-ubuntu-13.10"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box"

  config.omnibus.chef_version = "11.6.2"

  config.vm.network :forwarded_port, guest: 80, host: 3000

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./deploy/cookbooks"
    chef.roles_path = "./deploy/roles"
    chef.data_bags_path = "./deploy/data_bags"

    chef.run_list = "recipe[supermarket::default]"
  end
end
