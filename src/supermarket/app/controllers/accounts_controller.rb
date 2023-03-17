class AccountsController < ApplicationController
  before_action :authenticate_user!

  #
  # POST /auth/:provider/callback
  #
  # Create a new account with returned OAuth info
  # for the current user
  #
  def create
    account = current_user.account_from_oauth(request.env["omniauth.auth"])

    if account.save
      redirect_to after_link_location, notice: "Successfully
        connected #{request.env["omniauth.auth"]["provider"]}."
    else
      redirect_to edit_profile_path, alert: account.errors.full_messages.join(", ")
    end
  end

  #
  # DELETE /users/:user_id/accounts/:id
  #
  # Destroy an account
  # Unlinks connected account (either GitHub or Twitter) from the current_user.
  #
  def destroy
    current_user.accounts.find(params[:id]).destroy
    redirect_back notice: t("account.disconnected"), fallback_location: edit_profile_path
  end

  private

  def after_link_location
    stored_location || edit_profile_path
  end
end
