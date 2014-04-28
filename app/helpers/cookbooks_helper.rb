module CookbooksHelper
  #
  # Determine whether or not the user has permission to transfer ownership or
  # destroy the cookbook and yield those values to the block.
  #
  # @param cookbook [Cookbook]
  # @param collaborator [User]
  #
  # @yieldparam transfer [Boolean] permission to transfer ownership
  # @yieldparam destroy [Boolean] permission to destroy
  #
  def collaboration_permissions_for(cookbook, collaborator)
    transfer = policy(collaborator.collaborator_for_cookbook(cookbook)).transfer?
    destroy = policy(collaborator.collaborator_for_cookbook(cookbook)).destroy?
    yield transfer, destroy
  end

  #
  # If we have a linked cookbook for this dependency, allow the user to get to
  # it. Otherwise, just show the name
  #
  # @param dep [CookbookDependency]
  #
  # @return [String] The dependency info to show on the page
  #
  def dependency_link(dep)
    name_and_version = "#{dep.name} #{dep.version_constraint}"

    content_tag(:p) do
      if dep.cookbook
        link_to name_and_version, cookbook_url(dep.cookbook), rel: 'cookbook_dependency'
      else
        name_and_version
      end
    end
  end

  #
  # Return the correct state for a cookbook follow/unfollow button.
  #
  # @example
  #   <%= follow_button_for(@cookbook) %>
  #
  # @return [String] a link based on the following state for the current cookbook.
  #
  def follow_button_for(cookbook)
    fa_icon = content_tag(:i, '', class: 'fa fa-users')
    followers_count = cookbook.cookbook_followers_count.to_s
    followers_count_span = content_tag(
      :span, followers_count, class: 'cookbook_follow_count'
    )
    follow_html = fa_icon + 'Follow' + followers_count_span
    unfollow_html = fa_icon + 'Unfollow' + followers_count_span

    unless current_user
      return link_to(
        follow_cookbook_path(cookbook),
        method: 'put',
        rel: 'sign-in-to-follow',
        class: 'button radius tiny follow',
        title: 'You must be signed in to follow a cookbook.',
        'data-tooltip' => true
      ) do
        follow_html
      end
    end

    if cookbook.followed_by?(current_user)
      link_to(
        unfollow_cookbook_path(cookbook),
        method: 'delete',
        rel: 'unfollow',
        class: 'button radius tiny follow',
        id: 'unfollow_cookbook',
        'data-cookbook' => cookbook.name,
        'data-disable-with' => 'Unfollowing'
      ) do
        unfollow_html
      end
    else
      link_to(
        follow_cookbook_path(cookbook),
        method: 'put',
        rel: 'follow',
        class: 'button radius tiny follow',
        id: 'follow_cookbook',
        'data-cookbook' => cookbook.name,
        'data-disable-with' => 'Following'
      ) do
        follow_html
      end
    end
  end

  #
  # Generates a link to the current page with a parameter to sort cookbooks in
  # a particular way.
  #
  # @param linked_text [String] the contents of the +a+ tag
  # @param ordering [String] the name of the ordering
  #
  # @example
  #   link_to_sorted_cookbooks 'Recently Updated', 'recently_updated'
  #
  # @return [String] the generated anchor tag
  #
  def link_to_sorted_cookbooks(linked_text, ordering)
    if params[:order] == ordering
      link_to linked_text, params.except(:order), class: 'button radius secondary active'
    else
      link_to linked_text, params.merge(order: ordering), class: 'button radius secondary'
    end
  end
end
