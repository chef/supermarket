class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :define_search

  include Supermarket::Authorization
  include Supermarket::Authentication
  include Supermarket::LocationStorage
  include CustomUrlHelper

  rescue_from(
    NotAuthorizedError,
    ActiveRecord::RecordNotFound,
    ActionController::UnknownFormat,
    ActionView::MissingTemplate
  ) do |error|
    not_found!(error)
  end

  def define_search
    @search = { path: cookbooks_path, name: "Cookbooks" }
  end

  protected

  def not_found!(error = nil)
    raise error if error && Rails.env.development?

    options = { status: 404 }

    if error
      options[:notice] = error.message
    end

    respond_to do |format|
      format.html do
        render "exceptions/404", **options
      end
      format.json do
        render json: {}, **options
      end
    end
  end

  def after_sign_in_path_for(_resource)
    stored_location || root_path
  end

  #
  # Redirect the user to their profile page if they do not have any linked
  # GitHub accounts with the notice to instruct them to link a GitHub account
  #
  # If GitHub integration is disabled, just return true.
  #
  def require_linked_github_account!
    return unless Feature.active?(:github)

    unless current_user.linked_github_account?
      store_location!
      redirect_to link_github_profile_path, notice: t("requires_linked_github")
    end
  end
end
