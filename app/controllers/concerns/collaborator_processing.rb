module CollaboratorProcessing
  extend ActiveSupport::Concern

  included do
    helper_method :add_users_as_collaborators
  end

  def add_users_as_collaborators(resourceable_type, resourceable_id)
    resource = resourceable_type.constantize.find(
      resourceable_id
    )
  end


end
