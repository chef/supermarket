class ToolAuthorizer < Authorizer::Base
  #
  # Owners of a tool and Supermarket admins can edit it.
  #
  # @return [Boolean]
  #
  def edit?
    owner_or_collaborator? || user.is?(:admin)
  end

  #
  # Owners of a tool and Supermarket admins can update it.
  #
  # @return [Boolean]
  #
  def update?
    owner_or_collaborator? || user.is?(:admin)
  end

  #
  # Owners of a tool and Supermarket admins can delete it.
  #
  # @return [Boolean]
  #
  def destroy?
    owner? || user.is?(:admin)
  end

  #
  # Owners of a cookbook, collaborators of a cookbook and Supermarket admins can
  # manage a cookbook.
  #
  def manage?
    owner_or_collaborator? || user.is?(:admin)
  end

  #
  # Owners of a tool and Supermarket admins can add collaborators.
  #
  def create_collaborator?
    owner?
  end

  private

  def owner?
    record.owner == user
  end

  def owner_or_collaborator?
    owner? || record.collaborator_users.include?(user)
  end
end
