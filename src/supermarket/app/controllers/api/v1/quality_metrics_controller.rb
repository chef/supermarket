class Api::V1::QualityMetricsController < Api::V1Controller
  before_action :check_cookbook_name_present, except: :license_evaluation
  before_action :check_authorization, except: :license_evaluation
  before_action :find_cookbook_version, except: :license_evaluation

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

    # License metric has been deprecated in favor of the equivalent Foodcritic rule.
    # Remove old License metric results now that a Foodcritic result has been made that
    # checks for licensing.
    MetricResult
      .where(cookbook_version: @cookbook_version, quality_metric: QualityMetric.license_metric)
      .delete_all

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
  # License evaluation is handled by Foodcritic now, so this endpoint
  # is deprecation and will no longer accept License metric results.
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # Will return a 410 Gone because this resource has been intentionally removed
  #
  def license_evaluation
    response = { message: "Endpoint deprecated. License metric results are now produced by Foodcritic." }
    render json: response,
           status: 410
  end

  #
  # POST /api/v1/cookbook-versions/supported_platforms_evaluation
  #
  # Take the supported platforms evaluation results from Fieri and store them
  # as a metric result
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +supported_platforms_failure+, +supported_platforms_feedback+, and +fieri_key+.
  #
  def supported_platforms_evaluation
    require_supported_platforms_params

    create_metric(
      @cookbook_version,
      QualityMetric.supported_platforms_metric,
      params[:supported_platforms_failure],
      params[:supported_platforms_feedback]
    )

    head 200
  end

  # POST /api/v1/cookbook-versions/contributing_file_evaluation
  #
  # Take the supported platforms evaluation results from Fieri and store them
  # as a metric result
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +contributing_file_failure+, +contributing_file_feedback+, and +fieri_key+.
  #
  def contributing_file_evaluation
    require_contributing_file_params

    create_metric(
      @cookbook_version,
      QualityMetric.contributing_file_metric,
      params[:contributing_file_failure],
      params[:contributing_file_feedback]
    )

    head 200
  end

  def testing_file_evaluation
    require_testing_file_params

    create_metric(
      @cookbook_version,
      QualityMetric.testing_file_metric,
      params[:testing_file_failure],
      params[:testing_file_feedback]
    )

    head 200
  end

  def version_tag_evaluation
    require_version_tag_params

    create_metric(
      @cookbook_version,
      QualityMetric.version_tag_metric,
      params[:version_tag_failure],
      params[:version_tag_feedback]
    )

    head 200
  end

  # POST /api/v1/cookbook-versions/no_binaries_evaluation
  #
  # Take the contains no binaries evaluation results from Fieri and store them
  # as a metric result
  #
  # If the +CookbookVersion+ does not exist, render a 404 not_found.
  #
  # If the request is unauthorized, render unauthorized.
  #
  # This endpoint expects +cookbook_name+, +cookbook_version+,
  # +no_binaries_failure+, +no_binaries_feedback+, and +fieri_key+.
  #
  def no_binaries_evaluation
    require_no_binaries_params

    create_metric(
      @cookbook_version,
      QualityMetric.no_binaries_metric,
      params[:no_binaries_failure],
      params[:no_binaries_feedback]
    )

    head 200
  end

  rescue_from ActionController::ParameterMissing do |e|
    error(
      error_code: t("api.error_codes.invalid_data"),
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

  def require_supported_platforms_params
    params.require(:cookbook_name)
    params.require(:cookbook_version)
    params.require(:supported_platforms_failure)
    params.require(:supported_platforms_feedback)
  end

  def require_publish_params
    params.require(:cookbook_name)
    params.require(:publish_failure)
    params.require(:publish_feedback)
  end

  def require_contributing_file_params
    params.require(:cookbook_name)
    params.require(:contributing_file_failure)
    params.require(:contributing_file_feedback)
  end

  def require_testing_file_params
    params.require(:cookbook_name)
    params.require(:testing_file_failure)
    params.require(:testing_file_feedback)
  end

  def require_version_tag_params
    params.require(:cookbook_name)
    params.require(:cookbook_version)
    params.require(:version_tag_failure)
    params.require(:version_tag_feedback)
  end

  def require_no_binaries_params
    params.require(:cookbook_name)
    params.require(:cookbook_version)
    params.require(:no_binaries_failure)
    params.require(:no_binaries_feedback)
  end

  def create_metric(cookbook_version, quality_metric, failure, feedback)
    metric = MetricResult.create!(
      cookbook_version: cookbook_version,
      quality_metric: quality_metric,
      failure: failure,
      feedback: feedback
    )
    MetricResult
      .where(cookbook_version: cookbook_version, quality_metric: quality_metric)
      .where("id != ?", metric.id)
      .delete_all
    metric
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
    if params[:cookbook_name].blank?
      error(
        error_code: t("api.error_codes.invalid_data"),
        error_messages: [t("api.error_messages.missing_cookbook_name")]
      )
    end
  end

  def check_authorization
    unless ENV["FIERI_KEY"] == params["fieri_key"]
      render_not_authorized([t("api.error_messages.unauthorized_post_error")])
    end
  end
end
