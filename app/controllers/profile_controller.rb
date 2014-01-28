class ProfileController < ApplicationController
  before_filter :authenticate_user!

  #
  # PATCH /profile
  #
  # Update the current_user's attributes
  #
  def update
    current_user.update_attributes(user_params)

    redirect_to current_user, notice: 'Profile successfully updated.'
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

end
