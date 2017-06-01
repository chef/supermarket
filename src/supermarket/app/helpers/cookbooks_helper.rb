module CookbooksHelper
  #
  # Returns a URL for the latest version of the given cookbook
  #
  # @param cookbook [Cookbook]
  #
  # @return [String] the URL
  #
  def latest_cookbook_version_url(cookbook)
    api_v1_cookbook_version_url(
      cookbook, cookbook.latest_cookbook_version
    )
  end

  #
  # Show the contingent cookbook name and version
  #
  # @param contingent [CookbookDependency]
  #
  # @return [String] the link to the contingent cookbook
  #
  def contingent_link(dependency)
    version = dependency.cookbook_version
    cookbook = version.cookbook
    txt = "#{cookbook.name} #{version.version}"
    link_to(txt, cookbook_path(cookbook))
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

    content_tag(:td) do
      if dep.cookbook
        link_to name_and_version, cookbook_url(dep.cookbook), rel: 'cookbook_dependency'
      else
        name_and_version
      end
    end
  end

  #
  # Return the correct state for a cookbook follow/unfollow button. If given a
  # block, the result of the block will become the button's text.
  #
  # @example
  #   <%= follow_button_for(@cookbook) %>
  #   <%= follow_button_for(@cookbook) do |following| %>
  #     <%= following ? 'Stop Following' : 'Follow' %>
  #   <% end %>
  #
  # @param cookbook [Cookbook] the Cookbook to follow or unfollow
  # @param params [Hash] any additional query params to add to the follow button
  # @yieldparam following [Boolean] whether or not the +current_user+ is
  #   following the given +Cookbook+
  #
  # @return [String] a link based on the following state for the current cookbook.
  #
  def follow_button_for(cookbook, params = {}, &block)
    fa_icon = content_tag(:i, '', class: 'fa fa-users')
    followers_count = cookbook.cookbook_followers_count.to_s
    followers_count_span = content_tag(
      :span,
      number_with_delimiter(followers_count),
      class: 'cookbook_follow_count'
    )
    follow_html = fa_icon + 'Follow' + followers_count_span
    unfollow_html = fa_icon + 'Unfollow' + followers_count_span

    unless current_user
      return link_to(
        follow_cookbook_path(cookbook, params),
        method: 'put',
        rel: 'sign-in-to-follow',
        class: 'button radius tiny follow',
        title: 'You must be signed in to follow a cookbook.',
        'data-tooltip' => true
      ) do
        if block
          yield(false)
        else
          follow_html
        end
      end
    end

    if cookbook.followed_by?(current_user)
      link_to(
        unfollow_cookbook_path(cookbook, params),
        method: 'delete',
        rel: 'unfollow',
        class: 'button radius tiny follow',
        id: 'unfollow_cookbook',
        'data-cookbook' => cookbook.name,
        remote: true
      ) do
        if block
          yield(true)
        else
          unfollow_html
        end
      end
    else
      link_to(
        follow_cookbook_path(cookbook, params),
        method: 'put',
        rel: 'follow',
        class: 'button radius tiny follow',
        id: 'follow_cookbook',
        'data-cookbook' => cookbook.name,
        remote: true
      ) do
        if block
          yield(false)
        else
          follow_html
        end
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
  def link_to_sorted_cookbooks(linked_text, params, ordering)
    if params[:order] == ordering
      link_to linked_text, params.except(:order), class: 'button radius secondary active'
    else
      link_to linked_text, params.merge(order: ordering), class: 'button radius secondary'
    end
  end

  def foodcritic_info(feedback, failing_status = '')
    return 'No foodcritic feedback available' if feedback.nil?

    if failing_status == false # When a cookbook version passes foodcritic # The feedback from Fieri has a \n at the beginning # of it.
      feedback.gsub(/^\n/, '').html_safe
    else
      # When a cookbook version does not pass foodcritic
      # The feedback from Fieri includes \n in between
      # failing rules
      # This replaces those with <br /> tags for rendering
      feedback.gsub(/\n/, '<br />').html_safe
    end
  end
end
