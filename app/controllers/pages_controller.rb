class PagesController < ApplicationController
  #
  # GET /
  #
  # The first page a non-authenticated user sees. The welcome page gives the
  # user a taste of what Supermarket is all about.
  #
  def welcome
    redirect_to dashboard_path if current_user.present?

    @recently_updated_count = Cookbook.recently_updated.count
    @cookbook_count = Cookbook.count
    @download_count = Cookbook.sum(:download_count)
    @user_count = User.count
  end

  #
  # GET /dashboard
  #
  # The dashboard for authenticated users. This displays the user's cookbooks,
  # followed feed and the Supermarket haps.
  #
  def dashboard
    authenticate_user!

    if current_user.present?
      @owned_cookbooks = current_user.owned_cookbooks
      @collaborated_cookbooks = current_user.collaborated_cookbooks
    end
  end
end
