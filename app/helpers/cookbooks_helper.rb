module CookbooksHelper
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
        class: 'button follow',
        title: 'You must be signed in to follow a cookbook.',
        'data-tooltip' => true
      )
    end

    if cookbook.followed_by?(current_user)
      link_to(
        'Unfollow',
        unfollow_cookbook_path(cookbook),
        method: 'delete',
        remote: true,
        rel: 'unfollow',
        class: 'button follow'
      )
    else
      link_to(
        'Follow',
        follow_cookbook_path(cookbook),
        method: 'put',
        remote: true,
        rel: 'follow',
        class: 'button follow'
      )
    end
  end
end
