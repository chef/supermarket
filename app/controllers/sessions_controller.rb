class SessionsController < ApplicationController
  def create
    user = User.from_oauth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_url, notice: 'Logged in!'
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed out!'
  end
end
