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

  def search_path(controller_name)
    case controller_name
    when 'contributors'
      contributors_path
    when 'icla_signatures'
      icla_signatures_path
    when 'ccla_signatures'
      ccla_signatures_path
    end
  end

  def search_field_text(controller_name)
    case controller_name
    when 'contributors'
      'Search for a contributor by name, email, chef or github username'
    when 'icla_signatures'
      'Search for an ICLA signer by name or email'
    when 'ccla_signatures'
      'Search for a CCLA signer by company name'
    end
  end
end
