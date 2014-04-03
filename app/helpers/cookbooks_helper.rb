module CookbooksHelper
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
  # Return a title for cookbook feeds based on the parameters
  # that are currently set.
  #
  # @example
  #   <%= feed_title %>
  #
  # @return [String] a title based on the current paramters or All
  #
  def feed_title
    (params.fetch(:category, nil) || params.fetch(:order, nil) || 'All').titleize
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
    unless current_user
      return link_to(
        'Follow',
        follow_cookbook_path(cookbook),
        method: 'put',
        rel: 'sign-in-to-follow',
        class: 'button radius tiny follow',
        title: 'You must be signed in to follow a cookbook.',
        'data-tooltip' => true
      )
    end

    if cookbook.followed_by?(current_user)
      link_to(
        'Unfollow',
        unfollow_cookbook_path(cookbook),
        method: 'delete',
        rel: 'unfollow',
        class: 'button radius tiny follow',
        'data-disable-with' => 'Unfollowing'
      )
    else
      link_to(
        'Follow',
        follow_cookbook_path(cookbook),
        method: 'put',
        rel: 'follow',
        class: 'button radius tiny follow',
        'data-disable-with' => 'Following'
      )
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
    class_name = params[:order] == ordering ? 'active' : nil

    link_to linked_text, params.merge(order: ordering), class: class_name
  end
end
