module ContributorsHelper
  #
  # Returns a link to remove a contributor from a CCLA with different text and
  # rel depending on if the contributor belongs to the current user or not.
  #
  # @param [Contributor] the contributor to remove
  #
  # @example Remove contributor link for a given contributor
  #   remove_contributor_link_for(contributor)
  #
  # @return [String] a HTML link to remove a contributor
  #
  def remove_contributor_link_for(contributor)
    if contributor.user == current_user
      text = 'Remove Myself as a Contributor'
      rel = 'remove_self'
    else
      text = 'Remove Contributor'
      rel = 'remove_contributor'
    end

    link_to text, organization_contributor_url(contributor.organization, contributor),
            method: :delete, rel: rel, class: 'button secondary radius tiny'
  end

  #
  # Returns a string that will be unique within the DOM, suitable for use as an
  # id attribute for a DOM element
  #
  # @param contributor [User] the contributor
  #
  # @return [String] the unique DOM id
  #
  def contributor_options_id(contributor)
    "contributor-options-#{contributor.id}"
  end

  #
  # Show the appropriate text for removing collaborators from a resource. Owners
  # should see "Remove Collaborator", while collaborators should see "Remove
  # Myself".
  #
  # @param owner [User] the owner of a resource in question
  #
  # @return [String] the text for the removal link
  #
  def contributor_removal_text(owner)
    if current_user == owner
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
