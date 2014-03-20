class CookbooksController < ApplicationController
  #
  # GET /cookbooks/:id
  #
  # @todo Provide real maintainer and collaborator records to the view once
  # oc-id is in place
  #
  # Displays a cookbook.
  #
  def show
    @cookbook = Cookbook.with_name(params[:id]).first!
    @latest_version = @cookbook.get_version!('latest')
    @cookbook_versions = @cookbook.cookbook_versions
    @maintainer = User.first
    @collaborators = [User.first]
    @platforms = []
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
