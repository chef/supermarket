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
    followers_or_collaborators = [CookbookFollower, CookbookCollaborator].reduce([]) do |acc, klass|
      acc + klass.where(cookbook_id: id).includes(:user)
    end
    users = followers_or_collaborators.map(&:user).uniq.select(&:email_notifications)

    users.each do |user|
      CookbookMailer.delay.cookbook_deleted_email(cookbook['name'], user.email)
    end

    followers_or_collaborators.each { |f| f.destroy }
  end
end
