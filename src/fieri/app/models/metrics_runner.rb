require 'sidekiq'

class MetricsRunner
  include ::Sidekiq::Worker

  def perform(params)
    cookbook_data = cookbook_api_response(params)
    cookbook_version_data = cookbook_version_api_response(params)

    CollaboratorWorker.perform_async(cookbook_data)
    FoodcriticWorker.perform_async(params)
    PublishWorker.perform_async(cookbook_data, params['cookbook_name'])
    LicenseWorker.perform_async(cookbook_version_data, params['cookbook_name'])
  end

  private

  def cookbook_api_response(params)
    SupermarketApiRunner.new.cookbook_api_response(params['cookbook_name'])
  end

  def cookbook_version_api_response(params)
    SupermarketApiRunner.new.cookbook_version_api_response(params['cookbook_name'], params['cookbook_version'])
  end
end
