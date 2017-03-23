require 'sidekiq'

class MetricsRunner
  include ::Sidekiq::Worker

  def perform(params)
    cookbook_data = cookbook_api_response(params)
    cookbook_version_data = cookbook_version_api_response(params)

    CollaboratorWorker.perform_async(cookbook_data, params['cookbook_name'])
    FoodcriticWorker.perform_async(params)
    PublishWorker.perform_async(cookbook_data, params['cookbook_name'])
    LicenseWorker.perform_async(cookbook_version_data, params['cookbook_name'])
    SupportedPlatformsWorker.perform_async(cookbook_version_data, params['cookbook_name'])
    NoBinariesWorker.perform_async(params)

    # do not call metrics that depend on external services if running
    # in an airgapped environment
    return if ENV['AIR_GAPPED'] == 'true'
    external_service_metrics(cookbook_data, params['cookbook_name'], params['cookbook_version'])
  end

  private

  def cookbook_api_response(params)
    SupermarketApiRunner.new.cookbook_api_response(params['cookbook_name'])
  end

  def cookbook_version_api_response(params)
    SupermarketApiRunner.new.cookbook_version_api_response(params['cookbook_name'], params['cookbook_version'])
  end

  def external_service_metrics(cookbook_data, cookbook_name, cookbook_version)
    ContributingFileWorker.perform_async(cookbook_data, cookbook_name)
    TestingFileWorker.perform_async(cookbook_data, cookbook_name)
    VersionTagWorker.perform_async(cookbook_data, cookbook_name, cookbook_version)
  end
end
