class CookbookDeletionWorker
  include Sidekiq::Worker

  #
  # Notify anyone that was a follower or a collaborator on this cookbook that
  # it has been deleted. This will only email users with email notifications
  # turned on.
  #
  # @param [Hash] cookbook a hash representation of the cookbook to delete
  #
  def perform(cookbook)
    id = cookbook['id']

    subscribed_user_ids = SystemEmail.find_by!(name: 'Cookbook deleted')
                                     .subscribed_users
                                     .pluck(:id)

    followers_or_collaborators = CookbookFollower.where(cookbook_id: id)
                                                 .includes(:user) +
                                 Collaborator.where(resourceable_id: id,
                                                    resourceable_type: 'Cookbook')
                                             .includes(:user)

    users = followers_or_collaborators.map(&:user).uniq.select { |u| subscribed_user_ids.include?(u.id) }

    users.each do |user|
      CookbookMailer.cookbook_deleted_email(cookbook['name'], user).deliver_now
    end

    followers_or_collaborators.each(&:destroy)
  end
end
