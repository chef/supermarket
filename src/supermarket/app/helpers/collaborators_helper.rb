module CollaboratorsHelper
  def non_group_collaborators(collaborators)
    collaborators.where(group: nil)
  end

  def group_collaborators(collaborators, group)
    collaborators.where(group: group)
  end

  #
  # Returns a string that will be unique within the DOM, suitable for use as an
  # id attribute for a DOM element
  #
  # @param collaborator [User] the collaborator
  #
  # @return [String] the unique DOM id
  #
  def collaborator_options_id(collaborator)
    "collaborator-options-#{collaborator.id}"
  end

  #
  # Show the appropriate text for removing collaborators from a resource. Owners
  # should see "Remove Collaborator", while collaborators should see "Remove
  # Myself".
  #
  # @param collaborator [User] a collaborator of a resource in question
  #
  # @return [String] the text for the removal link
  #
  def collaborator_removal_text(collaborator)
    if current_user == collaborator
      'Remove Collaborator'
    else
      'Remove Myself'
    end
  end

  #
  # Determine whether or not the user has permission to transfer ownership or
  # destroy the resource and yield those values to the block.
  #
  # @param collaborator [User]
  #
  # @yieldparam transfer [Boolean] permission to transfer ownership
  # @yieldparam destroy [Boolean] permission to destroy
  #
  def collaboration_permissions_for(collaborator)
    transfer = policy(collaborator).transfer?
    destroy = policy(collaborator).destroy?
    yield transfer, destroy
  end
end
