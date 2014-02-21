class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  include Supermarket::Authorization
  include Supermarket::LocationStorage

  rescue_from NotAuthorizedError do |error|
    not_found!(error)
  end

  protected

  def not_found!(error = nil)
    options = { status: 404 }

    if error
      options[:notice] = error.message
    end

    render 'exceptions/404', options
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :first_name, :last_name,
        :password, :password_confirmation)
    end
  end

  def after_sign_in_path_for(resource)
    stored_location || root_path
  end

  #
  # Redirect the user to their profile page if they do not have any linked
  # GitHub accounts with the notice to instruct them to link a GitHub account
  # before signing an CCLA.
  #
  def require_linked_github_account!
    if !current_user.linked_github_account?
      store_location_for current_user, request.path

      redirect_to link_github_profile_path,
        notice: t('requires_linked_github')
    end
  end
end
