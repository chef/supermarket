class CookbookAuthorizer < Authorizer::Base
  #
  # Owners of a cookbook are the only ones that can add collaborators.
  #
  # @return [Boolean]
  #
  def create_collaborator?
    record.owner == user
  end

  #
  # Owners and collaborators of a cookbook can manage the cookbook's urls
  #
  # @return [Boolean]
  #
  def manage_cookbook_urls?
    record.owner == user || record.collaborators.include?(user)
  end
end
