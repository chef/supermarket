#
# Cookbook:: supermarket-deploy
# Recipe:: omnibus_standalone
#
# Copyright:: 2017, Chef Software Inc Engineering, All Rights Reserved.

################################################################
# Download SSL Certs from Citadel
################################################################

directory "/var/opt/supermarket/ssl/ca" do
  mode "0755"
  recursive true
end

file "/var/opt/supermarket/ssl/ca/wildcard.chef.co.crt" do
  mode "0600"
  content citadel['wildcard.chef.co.crt']
  sensitive true
end

file "/var/opt/supermarket/ssl/ca/wildcard.chef.co.key" do
  mode "0600"
  content citadel['wildcard.chef.co.key']
  sensitive true
end

################################################################
# Install Supermarket
################################################################

supermarket_ocid = Chef::JSONCompat.from_json(Chef::HTTP.new("https://#{server_fqdn_for('chef-server')}").get('/supermarket-credentials'))

chef_ingredient 'supermarket' do
  channel omnibus_channel_for_environment
  version version_for_environment('supermarket')
  config Chef::JSONCompat.to_json_pretty(
    fqdn: server_fqdn_for('supermarket'),
    host: server_fqdn_for('supermarket'),
    chef_server_url: "https://#{server_fqdn_for('chef-server')}",
    chef_oauth2_app_id: supermarket_ocid['uid'],
    chef_oauth2_secret: supermarket_ocid['secret'],
    ssl: {
      certificate: "/var/opt/supermarket/ssl/ca/wildcard.chef.co.crt",
      certificate_key: "/var/opt/supermarket/ssl/ca/wildcard.chef.co.key",
    }
  )

  action :upgrade
end

ingredient_config 'supermarket' do
  notifies :reconfigure, 'chef_ingredient[supermarket]'
end
