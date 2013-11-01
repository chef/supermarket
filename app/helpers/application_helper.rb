module ApplicationHelper
  #
  # The OmniAuth path for the given +provider+.
  #
  # @param [String, Symbol] provider
  #
  def auth_path(provider)
    "/auth/#{provider}"
  end
end
