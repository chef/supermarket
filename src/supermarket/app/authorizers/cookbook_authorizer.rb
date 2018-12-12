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
    ENV['OWNERS_CAN_REMOVE_ARTIFACTS'] == 'true' ? owner_or_admin? : admin?
  end

  #
  # Owners of a cookbook and Supermarket admins can manage a cookbook.
  #
  def manage?
    owner_or_admin?
  end

  #
  # Owners of a cookbook are the only ones that can add collaborators.
  #
  # @return [Boolean]
  #
  def create_collaborator?
    owner_or_admin?
  end

  #
  # Owners and collaborators of a cookbook and Supermarket admins can manage
  # the cookbook's urls.
  #
  # @return [Boolean]
  #
  def manage_cookbook_urls?
    owner_or_collaborator? || admin?
  end

  #
  # Admins can transfer ownership of a cookbook to another user.
  #
  # @return [Boolean]
  #
  def transfer_ownership?
    owner_or_admin?
  end

  #
  # Owners of a cookbook and Supermarket admins can deprecate a cookbook if
  # that cookbook is not already deprecated.
  #
  # @return [Boolean]
  #
  def deprecate?
    !record.deprecated? && owner_or_admin?
  end

  #
  # Owners of a cookbook and Supermarket admins can undeprecate a cookbook if
  # that cookbook is deprecated.
  #
  # @return [Boolean]
  #
  def undeprecate?
    record.deprecated? && owner_or_admin?
  end

  #
  # Owners of a cookbook and Supermarket admins can put a cookbook up for
  # adoption.
  #
  # @return [Boolean]
  #
  def manage_adoption?
    owner_or_admin?
  end

  #
  # Admins can toggle a cookbook as featured.
  #
  # @return [Boolean]
  #
  def toggle_featured?
    admin?
  end

  private

  def admin?
    user.is?(:admin)
  end

  def owner?
    record.owner == user
  end

  def owner_or_collaborator?
    owner? || record.collaborator_users.include?(user)
  end

  def owner_or_admin?
    owner? || admin?
  end
end
