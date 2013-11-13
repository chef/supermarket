# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
VM_MEMORY = ENV['VM_MEMORY'] || '4096'
VM_CPUS = ENV['VM_CPUS'] || '2'
VM_NFS = (ENV['VM_NFS'] && %w(1 true yes).include?(ENV['VM_NFS'])) || true

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.omnibus.chef_version = '11.8.0'

  config.vm.network :private_network, ip: '172.0.1.50'
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.synced_folder './', '/supermarket', nfs: VM_NFS
  config.vm.synced_folder './', '/vagrant', disabled: true

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box     = 'opscode-ubuntu-12.04'
    override.vm.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
    vb.customize ['modifyvm', :id, '--memory', VM_MEMORY]
    vb.customize ['modifyvm', :id, '--cpus', VM_CPUS]
  end

  config.vm.provider :vmware_fusion do |vmf, override|
    override.vm.box     = 'precise64'
    override.vm.box_url = 'http://files.vagrantup.com/precise64_vmware.box'
    vmf.vmx['memsize']  = VM_MEMORY
    vmf.vmx['numvcpus'] = VM_CPUS
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'chef/cookbooks'
    chef.roles_path     = 'chef/roles'
    chef.data_bags_path = 'chef/data_bags'

    chef.formatter = 'doc'
    chef.log_level = :warn

    chef.run_list = [
      'recipe[supermarket::default]'
    ]
  end
end
