module UsersHelper
  #
  # Return the image_tag of the specified user's gravatar based on their
  # email. If the user does not have a Gravatar, the default Gravatar image is
  # displayed. The default size is 48 pixels.
  #
  # @param user [User] the User for get the Gravatar for
  # @param options [Hash] options for the Gravatar
  # @option options [Integer] :size (48) the size of the Gravatar in pixels
  #
  # @example Gravtar for current_user
  #   gravatar_for current_user, size: 72
  #
  # @return [String] the HTML element for the image with the src being the
  #   user's Gravatar, the alt being the User's name and the class being
  #   gravatar.
  #
  def gravatar_for(user, options = {})
    Feature.active?(:gravatar) ? gravatar_image(user, options) : no_gravatar_image(user)
  end

  #
  # Outputs pluralized stats with contextually appropriate markup
  #
  # @param count [Integer] how many there are
  # @param thing [String] the thing that we have some of
  #
  # @return [String] the pluralized string with appropriate formatting
  #
  def pluralized_stats(count, thing)
    new_count, new_thing = pluralize(count, thing).split(' ')
    raw "#{new_count} #{content_tag(:span, new_thing)}"
  end

  private

  def gravatar_image(user, options = {})
    options = {
      size: 48
    }.merge(options)

    size = options[:size]
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar')
  end

  def no_gravatar_image(user)
    image_tag('apple-touch-icon.png', alt: user.name, class: 'gravatar')
  end
end
