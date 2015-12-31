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

  #
  # Returns flash message class for a given flash message name
  #
  # @param name [String]
  #
  # @return [String]
  #
  def flash_message_class_for(name)
    {
      'notice' => 'success',
      'alert' => 'alert',
      'warning' => 'warning'
    }.fetch(name)
  end

  #
  # Returns true if request comes from a mobile device, false if not
  #
  # @param user_agent [String]
  #
  # @return [Bool]
  #
  def mobile_device?(user_agent)
    user_agent.downcase =~ /Mobile|webOS/i ? true : false
  end
end
