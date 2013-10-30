module Supermarket
  module Extrication

    #
    # The list of classes that correspond to an authorization error
    #
    AUTHORIZATION_ERRORS = %w[
      Supermarket::Authorization::NoAuthorizerError
      Supermarket::Authorization::NotAuthorizedError
    ]

    #
    # The list of errors the should raise a 404
    #
    NOT_FOUND_ERRORS = %w[
      AbstractController::ActionNotFound
      ActionController::RoutingError
      ActionController::UnknownController
      ActiveRecord::RecordNotFound
    ]

    #
    # The list of classes that correspond to an OmniAuth error
    #
    OMNIAUTH_ERRORS = %w[
      OAuth::Unauthorized
      OmniAuth::Strategies::OAuth2::CallbackError
    ]

    #
    # The list of all other errors that could happen
    #
    SERVER_ERRORS = %w[
      Exception
      LoadError
    ]

    def self.included(base)
      unless Rails.env.development?
        base.class_eval do
          # Handlers are inherited. They are searched from right to left,
          # from bottom to top, and up the hierarchy.
          rescue_from *SERVER_ERRORS, with: :server_error

          rescue_from *AUTHORIZATION_ERRORS, with: :authorization_error
          rescue_from *NOT_FOUND_ERRORS,     with: :not_found_error
          rescue_from *OMNIAUTH_ERRORS,      with: :omniauth_error
        end
      end
    end

    private

      #
      # Fired when an authorization error is raised.
      #
      def authorization_error(exception)
        message = exception.message
        redirect_to root_path, alert: message, status: 401
      end

      #
      # Fired when a route or record is not found.
      #
      def not_found_error(exception)
        respond_to do |format|
          format.html { render template: 'errors/404', status: 404 }
          format.json { render json: { message: 'Not Found' }, status: 404 }
        end
      end

      #
      # Fired when an error is returned from OAuth.
      #
      def omniauth_error(exception)
        message = "OAuth Error: #{exception.message}"
        redirect_to root_path, alert: message, status: 401
      end

      #
      # Fired when any kind of exception happens.
      #
      # @todo Add some kind of logging/notifications here.
      #
      def server_error(exception)
        respond_to do |format|
          format.html { render template: 'errors/500', status: 500 }
          format.json { render json: { message: 'Server Error' }, status: 500 }
        end
      end
  end
end
