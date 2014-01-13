class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Supermarket::Authentication
  include Pundit

  rescue_from Pundit::NotAuthorizedError do |error|
    render 'exceptions/404', status: 404, notice: error.message
  end
end
