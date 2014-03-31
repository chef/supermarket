class CookbookVersionsController < ApplicationController
  before_filter :set_cookbook_and_version

  #
  # GET /cookbooks/:cookbook_id/versions/:version/download
  #
  # Redirects the user to the cookbook artifact
  #
  def download
    CookbookVersion.increment_counter(:download_count, @version.id)
    Cookbook.increment_counter(:download_count, @cookbook.id)

    SegmentIO.track_server_event(
      'cookbook_version_downloaded',
      cookbook: @cookbook.name,
      version: @version.version
    )

    redirect_to @version.tarball.url
  end

  #
  # GET /cookbooks/:cookbook_id/versions/:version
  #
  # Displays information about this particular cookbook version
  #
  def show
    @cookbook_versions = @cookbook.cookbook_versions
    @maintainer = User.first
    @collaborators = [User.first]
    @supported_platforms = @version.supported_platforms
  end

  private

  def set_cookbook_and_version
    @cookbook = Cookbook.with_name(params[:cookbook_id]).first!
    @version = @cookbook.get_version!(params[:version])
  end
end
