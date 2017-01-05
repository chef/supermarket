class Api::V1::QualityMetricsController < Api::V1Controller
  before_action :check_cookbook_name_present
  before_action :check_authorization
  before_action :find_cookbook_version

  #
  # POST /api/v1/quality_metrics/foodcritic_evaluation
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
  # POST /api/v1/quality_metrics/collaborators_evaluation
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
    require_publish_params

    create_metric(
      @cookbook_version,
      QualityMetric.publish_metric,
      params[:publish_failure],
      params[:publish_feedback]
    )

    head 200
  end

  #
  # POST /api/v1/cookbook-versions/license_evaluation
  #
  # Take the license evaluation results from Fieri and store them as a
  # metric result
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +license_failure+, +license_feedback+, and +fieri_key+.
  #
  def license_evaluation
    require_license_params

    create_metric(
      @cookbook_version,
      QualityMetric.license_metric,
      params[:license_failure],
      params[:license_feedback]
    )

    head 200
  end

  rescue_from ActionController::ParameterMissing do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: [t("api.error_messages.missing_#{e.param}")]
    )
  end

  private

  def require_evaluation_params
    params.require(:cookbook_name)
    params.require(:cookbook_version)
    params.require(:foodcritic_failure)
  end

  def require_collaborator_params
    params.require(:cookbook_name)
    params.require(:collaborator_failure)
    params.require(:collaborator_feedback)
  end

  def require_license_params
    params.require(:cookbook_name)
    params.require(:cookbook_version)
    params.require(:license_failure)
  end

  def require_publish_params
    params.require(:cookbook_name)
    params.require(:publish_failure)
    params.require(:publish_feedback)
  end

  def create_metric(cookbook_version, quality_metric, failure, feedback)
    existing_metric = MetricResult.where(cookbook_version: cookbook_version, quality_metric: quality_metric)

    unless existing_metric.empty?
      existing_metric.destroy_all
    end

      MetricResult.create!(
        cookbook_version: cookbook_version,
        quality_metric: quality_metric,
        failure: failure,
        feedback: feedback
      )
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

  def check_cookbook_name_present
    unless params[:cookbook_name].present?
      error(
        error_code: t('api.error_codes.invalid_data'),
        error_messages: [t("api.error_messages.missing_cookbook_name")]
      )
    end
  end

  def check_authorization
    unless ENV['FIERI_KEY'] == params['fieri_key']
      render_not_authorized([t('api.error_messages.unauthorized_post_error')])
    end
  end
end
