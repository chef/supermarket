#
# Cookbook:: supermarket-deploy
# Recipe:: omnibus_standalone
#
# Copyright:: 2017, Chef Software Inc Engineering, All Rights Reserved.

include_recipe 'supermarket-deploy::default'

supermarket_ocid = Chef::JSONCompat.from_json(Chef::HTTP.new("https://#{server_fqdn_for('chef-server')}").get('/supermarket-credentials'))

chef_ingredient 'supermarket' do
  channel omnibus_channel_for_environment
  version supermarket_version_for_environment
  config Chef::JSONCompat.to_json_pretty(
    fqdn: server_fqdn_for('supermarket'),
    host: server_fqdn_for('supermarket'),
    chef_server_url: "https://#{server_fqdn_for('chef-server')}",
    chef_oauth2_app_id: supermarket_ocid['uid'],
    chef_oauth2_secret: supermarket_ocid['secret']
  )

  action :upgrade
end

ingredient_config 'supermarket' do
  notifies :reconfigure, 'chef_ingredient[supermarket]'
end
