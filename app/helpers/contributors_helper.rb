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

    return link_to text, organization_contributor_url(contributor.organization, contributor),
      method: :delete, rel: rel, class: 'button secondary radius tiny'
  end
end
