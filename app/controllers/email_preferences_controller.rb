class EmailPreferencesController < ApplicationController
  #
  # GET /unsubscribe/:token
  #
  # This will unsubscribe a user from a specific email.
  #
  def unsubscribe
    @email_preference = EmailPreference.find_by!(token: params[:token])
    @email_preference.destroy
  end
end
