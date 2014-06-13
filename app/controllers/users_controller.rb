class UsersController < ApplicationController
  before_filter :assign_user

  #
  # GET /users/:id
  #
  # Display a user and a users cookbooks for a given context. The cookbooks
  # context is given via the tab paramter. Contexts include cookbooks the user
  # collaborates on, cookbooks the user follows and the default context of cookbooks
  # the user owns.
  #
  def show
    case params[:tab]
    when 'collaborates'
      @cookbooks = @user.collaborated_cookbooks
    when 'follows'
      @cookbooks = @user.followed_cookbooks
    else
      @cookbooks = @user.owned_cookbooks
    end

    @cookbooks = @cookbooks.order(:name).page(params[:page]).per(20)
  end

  #
  # PUT /users/:id/make_admin
  #
  # Assigns the admin role to a given user then redirects back to
  # the users profile.
  #
  def make_admin
    authorize! @user
    @user.update_attributes(roles: 'admin')
    redirect_to @user, notice: t('user.made_admin', name: @user.username)
  end

  private

  def assign_user
    @user = Account.for('chef_oauth2').with_username(params[:id]).first!.user
  end
end
