class SessionsController < ApplicationController
  def new
    if signed_in?
      return redirect_to root_path, notice: t('user.signed_in', name: current_user.name)
    end
  end

  def create
    user = User.from_oauth(request.env['omniauth.auth'], current_user)
    session[:user_id] = user.id
    redirect_to root_url, notice: t('user.signed_in', name: user.name)
  end

  def destroy
    reset_session
    redirect_to root_url, notice: t('user.signed_out')
  end
end
