#
# Lets those who follow and/or collaborate on a cookbook know when the cookbook
# has been deprecated.
#
class CookbookDeprecatedNotifier
  include Sidekiq::Worker

  #
  # Queues an email to each follower and/or collaborator of the cookbook
  #
  # @param cookbook_id [Fixnum] Identifies a +Cookbook+
  #
  def perform(cookbook_id)
    cookbook = Cookbook.find(cookbook_id)
    replacement_cookbook = cookbook.replacement

    users_to_email(cookbook).each do |user|
      CookbookMailer.delay.cookbook_deprecated_email(
        cookbook,
        replacement_cookbook,
        user.email
      )
    end
  end

  private

  def users_to_email(cookbook)
    users_to_email = []
    users_to_email << cookbook.owner
    users_to_email << cookbook.collaborator_users
    users_to_email << cookbook.followers

    users_to_email.flatten.uniq.select(&:email_notifications?)
  end
end
