class UsersController < ApplicationController
  #
  # GET /users/:id
  #
  # Display a user and a users cookbooks for a given context. The cookbooks
  # context is given via the tab paramter. Contexts include cookbooks the user
  # collaborates on, cookbooks the user follows and the default context of cookbooks
  # the user owns.
  #
  def show
    @user = Account.for('chef_oauth2').with_username(params[:id]).first!.user

    case params[:tab]
    when 'collaborates'
      @cookbooks = @user.collaborated_cookbooks
    when 'follows'
      @cookbooks = @user.followed_cookbooks
    else
      @cookbooks = @user.owned_cookbooks
    end
  end
end
