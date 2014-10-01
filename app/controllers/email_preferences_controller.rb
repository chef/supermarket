class EmailPreferencesController < ApplicationController
  #
  # GET /unsubscribe/:token
  #
  # This will unsubscribe a user from a specific email.
  #
  def unsubscribe
    @unsubscribe_request = UnsubscribeRequest.find_by!(token: params[:token])
    @unsubscribe_request.make_it_so
  end
end
