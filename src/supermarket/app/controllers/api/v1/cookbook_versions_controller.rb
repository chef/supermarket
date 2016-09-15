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
    @cookbook_version_metrics = @cookbook_version.metric_results
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

    if ENV['FIERI_KEY'] == params['fieri_key']
      cookbook_version = Cookbook.with_name(
        params[:cookbook_name]
      ).first!.get_version!(params[:cookbook_version])

      MetricResult.create!(
        cookbook_version: cookbook_version,
        quality_metric: QualityMetric.foodcritic_metric,
        failure: params[:foodcritic_failure],
        feedback: params[:foodcritic_feedback]
      )

      head 200
    else
      render_not_authorized([t('api.error_messages.unauthorized_post_error')])
    end
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

    if ENV['FIERI_KEY'] == params['fieri_key']
      cookbook_version = Cookbook.with_name(params[:cookbook_name]).first.cookbook_versions.last

      MetricResult.create!(
        cookbook_version: cookbook_version,
        quality_metric: QualityMetric.collaborator_num_metric,
        failure: params[:foodcritic_failure],
        feedback: params[:foodcritic_feedback]
      )

      head 200
    else
      render_not_authorized([t('api.error_messages.unauthorized_post_error')])
    end
  end

  rescue_from ActionController::ParameterMissing do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: [t("api.error_messages.missing_#{e.param}")]
    )
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
end
