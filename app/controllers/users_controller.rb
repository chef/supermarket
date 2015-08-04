class UsersController < ApplicationController
  before_filter :assign_user
  before_filter :override_search, only: [:tools]

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
  # GET /users/:id/tools
  #
  # Display a user and their tools.
  #
  def tools
    @tools = @user.tools.order(:name).page(params[:page]).per(20)
  end

  #
  # GET /users/:id/groups
  #
  # Display a user and their groups
  #
  def groups
    @groups = @user.memberships
  end

  #
  # GET /users/:id/followed_cookbook_activity
  #
  # Displays a feed of cookbook activity for the
  # cookbooks the specified user follows.
  #
  def followed_cookbook_activity
    @followed_cookbook_activity = @user.followed_cookbook_versions.limit(50)
  end

  #
  # PUT /users/:id/make_admin
  #
  # Assigns the admin role to a given user then redirects back to
  # the users profile.
  #
  def make_admin
    authorize! @user
    @user.roles = @user.roles + ['admin']
    @user.save
    redirect_to @user, notice: t('user.made_admin', name: @user.username)
  end

  #
  # DELETE /users/:id/revoke_admin
  #
  # Revokes the admin role to a given user then redirects back to
  # the users profile.
  #
  def revoke_admin
    authorize! @user
    @user.roles = @user.roles - ['admin']
    @user.save
    redirect_to @user, notice: t('user.revoked_admin', name: @user.username)
  end

  private

  def assign_user
    @user = Account.for('chef_oauth2').joins(:user).with_username(params[:id]).first!.user
  end

  def override_search
    @search = { path: tools_path, name: 'Tools' }
  end
end
