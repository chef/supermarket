module ProfileHelper
  #
  # Prepare a +User+ for display on the profile edit screen. This will add
  # empty +EmailPreference+ objects to the +User+ depending on how many
  # +SystemEmail+s exist in the system, and how many they're already subscribed
  # to. This makes the checkboxes on the form behave properly.
  #
  # @param user [User] the user being displayed on the profile edit screen
  #
  # @return [User] the same user, now ready to be displayed
  #
  def prep_email_preferences(user)
    (SystemEmail.all - user.system_emails).each do |system_email|
      user.email_preferences.build(system_email: system_email)
    end
    user
  end

  #
  # This sorts the +EmailPreference+s for a user, so the checkboxes on the
  # profile edit screen display in a consistent order. Without this, unchecked
  # boxes will be grouped at the bottom of the list.
  #
  # @param user [User] the user to sort preferences for
  #
  # @return [Array<EmailPreference>] sorted +EmailPreference+s
  #
  def sorted_email_preferences(user)
    user.email_preferences.sort_by { |ep| ep.system_email.name }
  end
end
