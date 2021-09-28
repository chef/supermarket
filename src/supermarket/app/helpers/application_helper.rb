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

    if name.last == "s"
      name + "'"
    else
      name + "'s"
    end
  end

  #
  # Returns flash message class for a given flash message name
  #
  # @param name [String]
  #
  # @return [String]
  #
  def flash_message_class_for(name)
    {
      "notice" => "success",
      "alert" => "alert",
      "warning" => "warning",
    }.fetch(name)
  end

  #
  # Returns a github user's profile url
  #
  # @param name [String]
  #
  # @return [String]
  #

  def github_profile_url(username)
    path = ENV["GITHUB_ENTERPRISE_URL"] || ENV["GITHUB_URL"]
    path += "/" unless path.end_with?("/")
    path + username
  end

  #
  # Returns a github account title
  #
  # @param name [String]
  #
  # @return [String]
  #
  def github_profile_title(name)
    "#{name} GitHub#{ENV["GITHUB_ENTERPRISE_URL"].present? ? " Enterprise" : ""} Username"
  end
end
