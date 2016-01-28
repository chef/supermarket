namespace :cookbook do

  # Usage: rake cookbook:grant_partner_badge cookbook=<cookbook_name>
  desc 'Grant the Partner badge to a cookbook'
  task grant_partner_badge: :environment do
    grant_badge_result = GrantBadgeToCookbook.new(badge: 'partner', cookbook: ENV['cookbook']).call
    puts grant_badge_result
  end
end
