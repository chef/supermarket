module CollaboratorProcessing
  extend ActiveSupport::Concern

  included do
    helper_method :add_users_as_collaborators
  end

  def add_users_as_collaborators(resource, user_ids)
    user_ids = user_ids.split(',') - ineligible_ids(resource)

    User.where(id: user_ids).each do |user|
      collaborator = Collaborator.new(
        user_id: user.id,
        resourceable: resource
      )

      # Passes object and action to Supermarket::Authorization,
      # which in turn passes them to Pundit for authorization
      authorize!(collaborator, 'create?')

      collaborator.save!
      CollaboratorMailer.delay.added_email(collaborator)
    end
  end

  private

  def ineligible_ids(resource)
    if Collaborator.ineligible_collaborators_for(resource)
      Collaborator.ineligible_collaborators_for(resource).map(&:id).map(&:to_s)
    else
      []
    end
  end
end
