class UsersController < ApplicationController
  #
  # GET /users/:id
  #
  # Display a user.
  #
  def show
    @user = Account.for('chef_oauth2').with_username(params[:id]).first!.user
  end
end
