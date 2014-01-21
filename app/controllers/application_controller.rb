class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Supermarket::Authentication
  include Supermarket::Authorization
  include Supermarket::LocationStorage

  rescue_from Pundit::NotAuthorizedError, NotAuthenticatedError, with: :not_found

  def not_found(error)
    render 'exceptions/404', status: 404, notice: error.message
  end
end
