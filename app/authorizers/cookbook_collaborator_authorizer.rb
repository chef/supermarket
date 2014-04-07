class CookbookCollaboratorAuthorizer < Authorizer::Base
  #
  # Owners of a cookbook are the only ones that can add collaborators.
  #
  # @return [Boolean]
  #
  def create?
    record.cookbook.owner == user
  end

  #
  # If you're an owner of a cookbook, you can remove any collaborator. If you
  # are a collaborator, then you should be able to remove yourself, but no one
  # else.
  #
  # @return [Boolean]
  #
  def destroy?
    create? || record.user == user
  end
end
