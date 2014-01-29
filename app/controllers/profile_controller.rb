class ProfileController < ApplicationController
  before_filter :authenticate_user!

  #
  # PATCH /profile
  #
  # Update the current_user's profile
  #
  def update
    if current_user.update_attributes(user_params)
      redirect_to current_user, notice: 'Profile successfully updated.'
    else
      render 'edit'
    end
  end

  #
  # PATCH /profile/change_password
  #
  # Change the current_user's password
  #
  def change_password
    if current_user.update_with_password(password_params)
      #
      # Sign in the user bypassing validation in case
      # their password changed.
      #
      sign_in current_user, bypass: true

      redirect_to current_user, notice: 'Password successfully changed.'
    else
      render 'edit'
    end
  end

  #
  # GET /profile/edit
  #
  # Display the edit form for the current_user
  #
  def edit
  end

  private

  #
  # The strong params for the user's profile.
  #
  def user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :company,
      :irc_nickname,
      :jira_username
    )
  end

  #
  # The strong params for the user's password.
  #
  def password_params
    params.require(:user).permit(
      :current_password,
      :password,
      :password_confirmation
    )
  end
end
