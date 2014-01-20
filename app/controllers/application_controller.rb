class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Supermarket::Authentication
  include Supermarket::Authorization

  rescue_from NotAuthorizedError do |error|
    render 'exceptions/404', status: 404, notice: error.message
  end
end
