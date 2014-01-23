class AccountsController < ApplicationController
  before_filter :authenticate_user!

  #
  # POST /auth/:provider/callback
  #
  # Create a new account with returned OAuth info
  # for the current user
  #
  def create
    account = current_user.account_from_oauth(request.env['omniauth.auth'])

    if account.save
      redirect_to current_user, notice: "Successfully
        connected #{params[:provider]}."
    else
      redirect_to current_user, alert: "Something went wrong
        while connecting #{params[:provider]}"
    end
  end
end
