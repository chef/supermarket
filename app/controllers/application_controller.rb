class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Supermarket::Authorization
  include Supermarket::Authentication
  include Supermarket::LocationStorage

  rescue_from(
    NotAuthorizedError,
    ActiveRecord::RecordNotFound,
    ActionController::UnknownFormat,
    ActionView::MissingTemplate
  ) do |error|
    not_found!(error)
  end

  protected

  def not_found!(error = nil)
    options = { status: 404 }

    if error
      options[:notice] = error.message
    end

    render 'exceptions/404.html.erb', options
  end

  def after_sign_in_path_for(_resource)
    stored_location || root_path
  end

  #
  # Redirect the user to their profile page if they do not have any linked
  # GitHub accounts with the notice to instruct them to link a GitHub account
  # before signing an CCLA.
  #
  def require_linked_github_account!
    unless current_user.linked_github_account?
      store_location!
      redirect_to link_github_profile_path,  notice: t('requires_linked_github')
    end
  end
end
