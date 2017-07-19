module ChefWorkflow
  module Helpers
    def environment
      node['terraform_environment'] || (node.chef_environment =~ /^acceptance.*$/ ? 'acceptance' : node.chef_environment)
    end

    def in_dev_or_acceptance?
      environment == 'acceptance' || node.chef_environment =~ /^dev/
    end

    # The channel to provide chef_ingredient
    def omnibus_channel_for_environment
      in_dev_or_acceptance? ? :unstable : :current
    end

    # The version to provide chef_ingredient
    def supermarket_version_for_environment
      node.attribute?('applications') && node['applications']['supermarket'] ? node['applications']['supermarket'] : 'latest'
    end

    def server_fqdn_for(product_key)
      if environment == 'delivered'
        # We drop the environment on our delivered instances
        "#{product_key}.chef.co"
      else
        # A-U-R instances include the environment
        "#{product_key}-#{environment}.chef.co"
      end
    end
  end
end

Chef::Node.send(:include, ChefWorkflow::Helpers)
Chef::Recipe.send(:include, ChefWorkflow::Helpers)
Chef::Resource.send(:include, ChefWorkflow::Helpers)
