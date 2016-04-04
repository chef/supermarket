module CollaboratorsHelper
  def non_group_collaborators(collaborators)
    collaborators.where(group: nil)
  end

  def group_collaborators(collaborators, group)
    collaborators.where(group: group)
  end
end
