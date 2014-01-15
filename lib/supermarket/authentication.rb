module Supermarket
  module Authentication

    # Custom error class raised when the user must be authenticated
    #
    class NotAuthenticatedError < StandardError; end

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

    #
    # Authentication action ensuring the current user exists.
    #
    # @raise [NotAuthenticatedError]
    #   if the user is not currently logged in
    #
    def require_user!
      unless signed_in?
        raise NotAuthenticatedError, 'You must be signed in to perform that' \
          ' action!'
      end
    end

  end
end
