class Api::V1::CookbookVersionsController < Api::V1Controller
  before_action :check_cookbook_name_present, only: [:foodcritic_evaluation, :collaborators_evaluation, :publish_evaluation]
  before_action :check_authorization, only: [:foodcritic_evaluation, :collaborators_evaluation, :publish_evaluation]
  before_action :find_cookbook_version, only: [:foodcritic_evaluation, :collaborators_evaluation, :publish_evaluation]
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
    Supermarket::Metrics.increment('cookbook.downloads.api')

    redirect_to @cookbook_version.tarball.url
  end

  #
  # POST /api/v1/cookbook-versions/foodcritic_evaluation
  #
  # Take the foodcritic evaluation results from Fieri and store them on the
  # applicable +CookbookVersion+.
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +foodcritic_failure+, +foodcritic_feedback+, and +fieri_key+.
  #
  def foodcritic_evaluation
    require_evaluation_params

    create_metric(
      @cookbook_version,
      QualityMetric.foodcritic_metric,
      params[:foodcritic_failure],
      params[:foodcritic_feedback]
    )

    head 200
  end

  #
  # POST /api/v1/cookbook-versions/collaborators_evaluation
  #
  # Take the collaborators evaluation results from Fieri and store them on the
  # applicable +CookbookVersion+.
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +collaborators_failure+, +collaborators_feedback+, and +fieri_key+.
  #
  def collaborators_evaluation
    require_collaborator_params

    create_metric(
      @cookbook_version,
      QualityMetric.collaborator_num_metric,
      params[:collaborator_failure],
      params[:collaborator_feedback]
    )

    head 200
  end

  rescue_from ActionController::ParameterMissing do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: [t("api.error_messages.missing_#{e.param}")]
    )
  end

  #
  # POST /api/v1/cookbook-versions/publish_evaluation
  #
  # Take the publish evaluation results from Fieri and store them as a
  # metric result
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +publish_failure+, +publish_feedback+, and +fieri_key+.
  #
  def publish_evaluation
    create_metric(
      @cookbook_version,
      QualityMetric.publish_metric,
      params[:publish_failure],
      params[:publish_feedback]
    )

    head 200
  end

  private

  def require_evaluation_params
    params.require(:fieri_key)
    params.require(:cookbook_name)
    params.require(:cookbook_version)
    params.require(:foodcritic_failure)
  end

  def require_collaborator_params
    params.require(:cookbook_name)
    params.require(:collaborator_failure)
    params.require(:collaborator_feedback)
  end

  def create_metric(cookbook_version, quality_metric, failure, feedback)
    MetricResult.create!(
      cookbook_version: cookbook_version,
      quality_metric: quality_metric,
      failure: failure,
      feedback: feedback
    )
  end

  def check_authorization
    unless ENV['FIERI_KEY'] == params['fieri_key']
      render_not_authorized([t('api.error_messages.unauthorized_post_error')])
    end
  end

  def check_cookbook_name_present
    unless params[:cookbook_name].present?
      error(
        error_code: t('api.error_codes.invalid_data'),
        error_messages: [t("api.error_messages.missing_cookbook_name")]
      )
    end
  end

  def find_cookbook_version
    @cookbook_version = if params[:cookbook_version]
                          Cookbook.with_name(
                            params[:cookbook_name]
                          ).first!.get_version!(params[:cookbook_version])
                        else
                          Cookbook.with_name(params[:cookbook_name]).first.latest_cookbook_version
                        end
  end
end
