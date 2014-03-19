class CookbooksController < ApplicationController
  #
  # GET /cookbooks/:id
  #
  # Displays a cookbook.
  #
  def show
    @cookbook = Cookbook.with_name(params[:id]).first!
    @latest_version = @cookbook.get_version!('latest')
  end

  #
  # GET /cookbooks/:id/download
  #
  # Redirects to the download location for the latest version of this cookbook.
  #
  def download
    cookbook = Cookbook.with_name(params[:id]).first!
    latest_version = cookbook.get_version!('latest')
    redirect_to cookbook_version_download_url(cookbook, latest_version)
  end
end
