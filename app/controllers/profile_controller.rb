class ProfileController < ApplicationController
  before_filter :authenticate_user!, except: [:update_install_preference]

  #
  # PATCH /profile
  #
  # Update the current_user's profile
  #
  def update
    if current_user.update_attributes(user_params)
      redirect_to current_user, notice: t('profile.updated')
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

  #
  # POST /profile/update_install_preference
  #
  # Update the current_user's install preference
  #
  def update_install_preference
    if current_user.present?
      current_user.update_install_preference(preference_param)

      head(200)
    else
      head(404)
    end
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
      email_preferences: []
    )
  end

  def preference_param
    params.require(:preference)
  end
end
