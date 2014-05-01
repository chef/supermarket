module UsersHelper
  #
  # Return the image_tag of the specified user's gravatar based on their
  # email. If the user does not have a Gravatar, the default Gravatar image is
  # displayed. The default size is 48 pixels.
  #
  # @param user [User] the User for get the Gravatar for
  # @param options [Hash] options for the user and Gravatar
  # @option options [Integer] :size (48) the size of the Gravatar in pixels
  # @option options [Boolean] :show_name whether or not to display the user's
  # name next to their gravatar
  #
  # @example Gravtar for current_user
  #   gravatar_for current_user, size: 72
  #
  # @return [String] the HTML element for the image with the src being the
  #   user's Gravatar, the alt being the User's name and the class being
  #   gravatar.
  #
  def gravatar_for(user, options = {})
    options = {
      size: 48
    }.merge(options)

    size = options[:size]
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    result = image_tag(gravatar_url, alt: user.name, class: 'gravatar')

    if options[:show_name]
      content_tag(:span) do
        result + " #{user.name}"
      end
    else
      result
    end
  end
end
