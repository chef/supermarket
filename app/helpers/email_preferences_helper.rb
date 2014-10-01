module EmailPreferencesHelper
  #
  # This translates a symbol or string representing the name of an email
  # preference into a descriptive name for displaying in the view.
  #
  # @param name [String, Symbol] the short name of the email preference
  #
  # @return [String] the descriptive name
  #
  def pretty_email_name(name)
    case name.to_sym
    when :new_version then 'New cookbook version'
    when :deleted then 'Cookbook deleted'
    when :deprecated then 'Cookbook deprecated'
    end
  end
end
