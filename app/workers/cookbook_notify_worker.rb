class CookbookNotifyWorker
  include Sidekiq::Worker

  #
  # Notify all followers that a new version of the specified +Cookbook+ has been updated.
  #
  # @param [Integer] cookbook_id the id for the Cookbook
  #
  def perform(cookbook_id)
    cookbook = Cookbook.find(cookbook_id)

    emailable_cookbook_followers = cookbook.cookbook_followers.
      joins(:user).
      where('users.email_notifications = ?', true)

    emailable_cookbook_followers.each do |cookbook_follower|
      CookbookMailer.delay.follower_notification_email(cookbook_follower)
    end
  end
end
