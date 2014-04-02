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
end
