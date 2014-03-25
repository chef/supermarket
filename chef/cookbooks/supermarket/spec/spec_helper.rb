require 'chefspec'
require 'chefspec/server'
require 'chefspec/berkshelf'

require 'json'

def configure_chef
  key = Tempfile.new('chef-zero-key')
  key.write(ChefZero::PRIVATE_KEY)
  key.flush
  Chef::Config[:node_name] = 'chef-zero'
  Chef::Config[:client_key] = key.path
end

def upload_databag(name, item)
  filename = File.join('.', '..', '..', 'data_bags', name, "#{item}.json")

  databag = Chef::DataBag.new
  databag.name(name)
  databag.save

  databag_item = Chef::DataBagItem.new
  databag_item.data_bag(name)
  databag_item.raw_data = JSON.parse(IO.read(filename))
  databag_item.save
end
