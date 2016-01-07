namespace :cookbook do

  # Usage: rake cookbook:enable_partnert_cookbook <cookbook_name>
  desc 'Enable the Partner Cookbook icon for a cookbook'
  task enable_partner_cookbook: :environment do
    cookbook = Cookbook.with_name(ENV['cookbook']).first!
    cookbook.partner = true
    cookbook.save
  end
end
