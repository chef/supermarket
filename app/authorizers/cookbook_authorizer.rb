class CookbookAuthorizer < Authorizer::Base
  #
  # Owners of a cookbook are the only ones that can add collaborators.
  #
  # @return [Boolean]
  #
  def create_collaborator?
    record.owner == user
  end
end
