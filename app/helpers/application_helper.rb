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
  # Returns a possessive version of the string
  #
  # @param name [String]
  #
  # @return [String]
  #
  def posessivize(name)
    return name if name.blank?

    if name.last == 's'
      name + "'"
    else
      name + "'s"
    end
  end
end
