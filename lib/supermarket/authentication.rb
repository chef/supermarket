module Supermarket
  module Authentication
    def self.included(controller)
      controller.send(:helper_method, :current_user, :signed_in?)
    end

    #
    # The currently logged in user, or nil if there is no user logged in.
    #
    # @return [User, nil]
    #
    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    end

    #
    # Determine if a user is currently logged in.
    #
    # @return [Boolean]
    #
    def signed_in?
      !!current_user
    end
  end
end
