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

  def github_eneterprise_enabled?
    ENV["GITHUB_ENTERPRISE_URL"].present? &&
      (ENV["GITHUB_ENTERPRISE_URL"] != "YOUR_GITHUB_ENTERPRISE_URL") &&
      ENV["GITHUB_CLIENT_OPTION_SITE"].present? &&
      (ENV["GITHUB_CLIENT_OPTION_SITE"] != "YOUR_GITHUB_ENTERPRISE_SITE") &&
      ENV["GITHUB_CLIENT_OPTION_AUTHORIZE_URL"].present? &&
      (ENV["GITHUB_CLIENT_OPTION_AUTHORIZE_URL"] != "YOUR_GITHUB_ENTERPRISE_AUTHORIZE_URL") &&
      ENV["GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL"].present? &&
      (ENV["GITHUB_CLIENT_OPTION_ACCESS_TOKEN_URL"] != "YOUR_GITHUB_ENTERPRISE_ACCESS_TOKEN_URL")
  end

  def github_profile_url(username)
    path = github_eneterprise_enabled? ? ENV["GITHUB_ENTERPRISE_URL"] : ENV["GITHUB_URL"]
    path += "/" unless path.end_with?("/")
    path + username
  end

  #
  # Returns a github account type
  #
  # @return [String]
  #

  def github_account_type
    github_eneterprise_enabled? ? "GitHub Enterprise" : "GitHub"
  end
end
