class CookbookVersionsController < ApplicationController
  before_filter :set_cookbook_and_version

  #
  # GET /cookbooks/:cookbook_id/versions/:version/download
  #
  # Redirects the user to the cookbook artifact
  #
  def download
    CookbookVersion.increment_counter(:web_download_count, @version.id)
    Cookbook.increment_counter(:web_download_count, @cookbook.id)
    Supermarket::Metrics.increment('cookbook.downloads.web')

    redirect_to cookbook_url
  end

  #
  # GET /cookbooks/:cookbook_id/versions/:version
  #
  # Displays information about this particular cookbook version
  #
  def show
    @cookbook_versions = @cookbook.sorted_cookbook_versions
    @owner = @cookbook.owner
    @collaborators = @cookbook.collaborators
    @supported_platforms = @version.supported_platforms
    @owner_collaborator = Collaborator.new resourceable: @cookbook, user: @owner
  end

  private

  def set_cookbook_and_version
    @cookbook = Cookbook.with_name(params[:cookbook_id]).first!
    @version = @cookbook.get_version!(params[:version])
  end

  def cookbook_url
    if ENV['S3_URLS_EXPIRE'].present?
      @version.tarball.expiring_url(ENV['S3_URLS_EXPIRE'])
    else
      @version.tarball.url
    end
  end
end
