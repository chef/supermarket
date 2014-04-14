module CollaboratorsHelper
  #
  # Determines if the current user is a collaborator of the given cookbook
  #
  # @param cookbook [Cookbook]
  #
  # @return [Boolean]
  #
  def collaborator?(cookbook, collaborator)
    cookbook.collaborators.include?(current_user) && collaborator == current_user
  end

  #
  # Determines if the current user is the owner of the given cookbook
  #
  # @param cookbook [Cookbook]
  #
  # @return [Boolean]
  #
  def owner?(cookbook)
    cookbook.owner == current_user
  end
end
