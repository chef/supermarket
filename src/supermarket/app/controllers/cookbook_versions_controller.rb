class CookbookVersionsController < ApplicationController
  before_action :set_cookbook_and_version

  #
  # GET /cookbooks/:cookbook_id/versions/:version/download
  #
  # Redirects the user to the cookbook artifact
  #
  def download
    CookbookVersion.increment_counter(:web_download_count, @version.id)
    Cookbook.increment_counter(:web_download_count, @cookbook.id)
    Supermarket::Metrics.increment("cookbook.downloads.web")

    # Ignore brakeman error: "Possible unprotected redirect"
    # as this might be an external URL that needs to be considered along with the host URL
    redirect_to @version.cookbook_artifact_url
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

    @public_metric_results = @version.metric_results.open.sorted_by_name
    @admin_metric_results = @version.metric_results.admin_only.sorted_by_name
  end

  private

  def set_cookbook_and_version
    @cookbook = Cookbook.with_name(params[:cookbook_id]).first!
    @version = @cookbook.get_version!(params[:version])
  end
end
