class UsersController < ApplicationController
  #
  # GET /users/:id
  #
  # Display a user.
  #
  def show
    @user = User.find(params[:id])
  end
end
