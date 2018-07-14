class CookbookVersionsController < ApplicationController
  before_action :set_cookbook_and_version, except: :index

  #
  # GET /cookbooks/versions
  #
  # Returns a collection of cookbook versions (releases)
  #
  def index
    index_params = params.permit(:page, :owned_by)
    @page = index_params[:page].to_i

    @cookbook_versions = CookbookVersion.includes(:cookbook, :user)
                                        .order('id desc')
                                        .page(@page)
                                        .per(20)

    if index_params[:owned_by].present?
      @cookbook_versions.owned_by(index_params[:owned_by])
    end

    respond_to do |format|
      format.atom { render layout: false }
    end
  end

  #
  # GET /cookbooks/:cookbook_id/versions/:version/download
  #
  # Redirects the user to the cookbook artifact
  #
  def download
    CookbookVersion.increment_counter(:web_download_count, @version.id)
    Cookbook.increment_counter(:web_download_count, @cookbook.id)
    Supermarket::Metrics.increment('cookbook.downloads.web')

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
