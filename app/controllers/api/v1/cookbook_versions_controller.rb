class Api::V1::CookbookVersionsController < Api::V1Controller
  #
  # GET /api/v1/cookbooks/:cookbook/versions/:version
  #
  # Return a specific CookbookVersion. Returns a 404 if the +Cookbook+ or
  # +CookbookVersion+ does not exist.
  #
  # @example
  #   GET /api/v1/cookbooks/redis/versions/1.1.0
  #
  def show
    @cookbook = Cookbook.with_name(params[:cookbook]).first!
    @cookbook_version = @cookbook.get_version!(params[:version])
  end

  #
  # GET /api/v1/cookbooks/:cookbook/versions/:version/download
  #
  # Redirects the user to the cookbook artifact
  #
  def download
    @cookbook = Cookbook.with_name(params[:cookbook]).first!
    @cookbook_version = @cookbook.get_version!(params[:version])

    CookbookVersion.increment_counter(:api_download_count, @cookbook_version.id)
    Cookbook.increment_counter(:api_download_count, @cookbook.id)

    SegmentIO.track_server_event(
      'cookbook_version_api_download',
      cookbook: @cookbook.name,
      version: @cookbook_version.version
    )

    redirect_to @cookbook_version.tarball.url
  end
end
