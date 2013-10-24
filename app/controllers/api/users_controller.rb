class Api::UsersController < Api::ApplicationController
  def index
    @users = User.order(:last_name, :first_name)
  end

  def show
    @user = User.find(params[:id])
  end
end
