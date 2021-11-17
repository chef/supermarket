require "sidekiq"

class MetricsRunner
  include ::Sidekiq::Worker

  def perform(cookbook)
    cookbook_data = cookbook_api_response(cookbook)
    cookbook_version_data = cookbook_version_api_response(cookbook)

    CollaboratorWorker.perform_async(cookbook_data, cookbook["name"])
    CookstyleWorker.perform_async(cookbook)
    SupportedPlatformsWorker.perform_async(cookbook_version_data, cookbook["name"])
    NoBinariesWorker.perform_async(cookbook)

    # do not call metrics that depend on external services if running
    # in an airgapped environment
    return if ENV["AIR_GAPPED"] == "true"

    external_service_metrics(cookbook_data, cookbook["name"], cookbook["version"])
  end

  private

  def cookbook_api_response(cookbook)
    SupermarketApiRunner.new.cookbook_api_response(cookbook["name"])
  end

  def cookbook_version_api_response(cookbook)
    SupermarketApiRunner.new.cookbook_version_api_response(cookbook["name"], cookbook["version"])
  end

  def external_service_metrics(cookbook_data, cookbook_name, cookbook_version)
    ContributingFileWorker.perform_async(cookbook_data, cookbook_name)
    TestingFileWorker.perform_async(cookbook_data, cookbook_name)
    VersionTagWorker.perform_async(cookbook_data, cookbook_name, cookbook_version)
  end
end
