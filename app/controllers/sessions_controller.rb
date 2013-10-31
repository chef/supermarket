class SessionsController < ApplicationController
  def create
    user = User.from_oauth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_url, notice: "Welcome back #{user.name}!"
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Logged out!'
  end
end
