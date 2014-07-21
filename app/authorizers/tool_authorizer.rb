class ToolAuthorizer < Authorizer::Base
  #
  # Owners of a tool and Supermarket admins can edit it.
  #
  # @return [Boolean]
  #
  def edit?
    owner? || user.is?(:admin)
  end

  #
  # Owners of a tool and Supermarket admins can update it.
  #
  # @return [Boolean]
  #
  def update?
    owner? || user.is?(:admin)
  end

  #
  # Owners of a tool and Supermarket admins can delete it.
  #
  # @return [Boolean]
  #
  def destroy?
    owner? || user.is?(:admin)
  end

  private

  def owner?
    record.owner == user
  end
end
