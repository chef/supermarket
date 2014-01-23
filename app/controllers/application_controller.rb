class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  include Supermarket::Authorization
  include Supermarket::LocationStorage

  rescue_from NotAuthorizedError do |error|
    render 'exceptions/404', status: 404, notice: error.message
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :first_name, :last_name,
        :password, :password_confirmation)
    end
  end

  def after_sign_in_path_for(resource)
    stored_location || root_path
  end
end
