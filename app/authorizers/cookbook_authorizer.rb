class CookbookAuthorizer < Authorizer::Base
  #
  # Owners and collaborators of a cookbook can publish new versions of a cookbook.
  #
  def create?
    owner_or_collaborator?
  end

  #
  # Owners of a cookbook can destroy a cookbook.
  #
  def destroy?
    owner?
  end

  #
  # Owners of a cookbook are the only ones that can add collaborators.
  #
  # @return [Boolean]
  #
  def create_collaborator?
    owner?
  end

  #
  # Owners and collaborators of a cookbook can manage the cookbook's urls.
  #
  # @return [Boolean]
  #
  def manage_cookbook_urls?
    owner_or_collaborator?
  end

  #
  # Admins can transfer ownership of a cookbook to another user.
  #
  # @return [Boolean]
  #
  def transfer_ownership?
    user.is?(:admin)
  end

  #
  # Owners of a cookbook and Supermarket admins can deprecate a cookbook if
  # that cookbook is not already deprecated.
  #
  # @return [Boolean]
  #
  def deprecate?
    !record.deprecated? && (owner? || user.is?(:admin))
  end

  #
  # Admins can toggle a cookbook as featured.
  #
  # @return [Boolean]
  #
  def toggle_featured?
    user.is?(:admin)
  end

  private

  def owner?
    record.owner == user
  end

  def owner_or_collaborator?
    owner? || record.collaborators.include?(user)
  end
end
