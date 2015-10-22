module CollaboratorProcessing
  extend ActiveSupport::Concern

  included do
    helper_method :add_users_as_collaborators
  end

  def add_users_as_collaborators(resourceable_type, resourceable_id, user_ids)
    resource = resourceable_type.constantize.find(
      resourceable_id
    )

    Collaborator.ineligible_collaborators_for(resource).map(&:id).map(&:to_s)

    user_ids = user_ids.split(',') - ineligible_ids(resource)
    User.where(id: user_ids)

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
