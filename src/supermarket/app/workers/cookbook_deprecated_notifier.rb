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
      CookbookMailer.cookbook_deprecated_email(
        cookbook,
        replacement_cookbook,
        user
      ).deliver_now
    end
  end

  private

  def users_to_email(cookbook)
    subscribed_user_ids = SystemEmail.find_by!(name: 'Cookbook deprecated')
                                     .subscribed_users
                                     .pluck(:id)

    users_to_email = []
    users_to_email << cookbook.owner
    users_to_email << cookbook.collaborator_users.where(id: subscribed_user_ids)
    users_to_email << cookbook.followers.where(id: subscribed_user_ids)

    users_to_email.flatten.uniq
  end
end
