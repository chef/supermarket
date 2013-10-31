module ApplicationHelper
  #
  # The OmniAuth path for the given +provider+.
  #
  # @param [String, Symbol] provider
  #
  def auth_path(provider)
    "/auth/#{provider}"
  end

  #
  # Create an OmniAuth button for the given provider.
  #
  # @example
  #   omniauth_button('GitHub')
  #
  # @param [String] provider
  #   the string of text you want the link to appear as
  #
  def omniauth_button(provider)
    key = provider.downcase.to_sym

    content_tag(:li, class: key) do
      link_to(provider, auth_path(key))
    end
  end
end
