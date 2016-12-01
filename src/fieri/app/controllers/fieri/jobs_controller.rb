require_dependency 'fieri/application_controller'

module Fieri
  class JobsController < ApplicationController
    def create
      CollaboratorWorker.perform_async(job_params[:cookbook_name])
      FoodcriticWorker.perform_async(job_params)
      PublishWorker.perform_async(job_params[:cookbook_name])

      LicenseWorker.perform_async(cookbook_version_response, params[:cookbook_name])
      render json: { status: 'ok' }.to_json
    rescue ActionController::ParameterMissing => e
      render status: 400, json: { status: 'error',
                                  message: e.message }
    end

    private

    def job_params
      [:cookbook_name, :cookbook_version, :cookbook_artifact_url].each do |param|
        params.require(param)
      end
      params
    end

    def cookbook_version_response
      uri = URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{params['cookbook_name']}/versions/#{params['cookbook_version']}")
      Net::HTTP.get(uri)
    end
  end
end
