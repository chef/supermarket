require_dependency "fieri/application_controller"

module Fieri
  class JobsController < ApplicationController
    def create
      CookbookWorker.perform_async(job_params)
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
  end
end
