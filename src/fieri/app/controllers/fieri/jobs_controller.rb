require_dependency "fieri/application_controller"

module Fieri
  class JobsController < ApplicationController
    def create
      CookbookWorker.perform_async(job_params)
      render text: "ok"
    rescue ActionController::ParameterMissing => e
      render status: 400, text: "Error: #{e.message}"
    end

    private

    def job_params
      [:cookbook_name, :cookbook_version, :cookbook_artifact_url].each do |param|
        params.require(param)
      end
    end
  end
end
