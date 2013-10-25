class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

    #
    # The currently logged in user, or nil if there is no user logged in.
    #
    # @return [User, nil]
    #
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user

    #
    # Determine if a user is currently logged in.
    #
    # @return [Boolean]
    #
    def logged_in?
      !!current_user
    end
    helper_method :logged_in?
end
