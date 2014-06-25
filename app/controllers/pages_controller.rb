class PagesController < ApplicationController
  before_filter :authenticate_user!, only: :dashboard

  #
  # GET /
  #
  # The first page a non-authenticated user sees. The welcome page gives the
  # user a taste of what Supermarket is all about.
  #
  def welcome
    redirect_to dashboard_path if current_user.present?

    @cookbook_count = Cookbook.count
    @user_count = User.count
  end

  #
  # GET /dashboard
  #
  # The dashboard for authenticated users. This displays the user's cookbooks,
  # collaborated cookbooks and new versions of cookbooks that the user follows.
  #
  def dashboard
    @cookbooks = current_user.owned_cookbooks.limit(5)
    @collaborated_cookbooks = current_user.collaborated_cookbooks.limit(5)
    @followed_cookbook_activity = current_user.followed_cookbook_versions.order('created_at DESC').limit(50)
  end
end
