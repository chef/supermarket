class SessionsController < ApplicationController
  include LocationStorage

  def new
    if signed_in?
      return redirect_to stored_location_or_root,
        notice: t('user.signed_in', name: current_user.name)
    end
  end

  def create
    user = User.from_oauth(request.env['omniauth.auth'], current_user)
    session[:user_id] = user.id
    redirect_to stored_location_or_root,
      notice: t('user.signed_in', name: user.name)
  end

  def destroy
    reset_session
    redirect_to stored_location_or_root, notice: t('user.signed_out')
  end

  private
    def stored_location_or_root
      stored_location || root_url
    end
end
