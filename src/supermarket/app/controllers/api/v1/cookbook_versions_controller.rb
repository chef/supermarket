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
    @cookbook_version_metrics = @cookbook_version.metric_results.includes(:quality_metric)
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
    Supermarket::Metrics.increment("cookbook.downloads.api")

    # Ignore brakeman error: "Possible unprotected redirect"
    # as this might be an external URL that needs to be considered along with the host URL
    redirect_to @cookbook_version.cookbook_artifact_url, allow_other_host: true
  end
end
