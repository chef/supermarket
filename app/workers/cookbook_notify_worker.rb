class CookbookNotifyWorker
  include Sidekiq::Worker

  #
  # Notify all followers that a new version of the specified +Cookbook+ has been updated.
  # This will only email the follower if the user has email notifications turned on.
  # This will not email users with an OCID oauth token of 'imported' to prevent migrated users
  # from being sent emails until they've logged into Supermarket.
  #
  # @param [Integer] cookbook_id the id for the Cookbook
  #
  def perform(cookbook_id)
    cookbook = Cookbook.find(cookbook_id)

    active_user_ids = User.joins(:accounts).
      where('provider = ? AND oauth_token != ?', 'chef_oauth2', 'imported').
      pluck(:id)

    emailable_cookbook_followers = cookbook.cookbook_followers.
      joins(:user).
      where(users: { email_notifications: true, id: active_user_ids })

    emailable_cookbook_followers.each do |cookbook_follower|
      CookbookMailer.delay.follower_notification_email(cookbook_follower)
    end
  end
end
