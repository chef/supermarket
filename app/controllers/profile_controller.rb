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
  # GET /profile/edit
  #
  # Display the edit form for the current_user
  #
  def edit
    @user = current_user
    @pending_requests = @user.pending_contributor_requests
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
      :twitter_username,
      :irc_nickname,
      :jira_username,
      :email_notifications
    )
  end
end
