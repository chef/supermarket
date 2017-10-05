require_dependency 'fieri/application_controller'

module Fieri
  class JobsController < ApplicationController
    before_action :check_authorization

    def create
      MetricsRunner.perform_async(job_params.to_h)
      render json: { status: 'ok' }.to_json
    end

    private

    def job_params
      params.require(:cookbook).permit(:name, :version, :artifact_url).tap do |cookbook_params|
        cookbook_params.require([:name, :version, :artifact_url])
      end
    end

    def check_authorization
      unless fieri_key == params.require(:fieri_key)
        error = {
          error_code: t('api.error_codes.unauthorized'),
          error_messages: [t('api.error_messages.unauthorized_post_error')]
        }
        render json: error, status: 401
      end
    end

    def fieri_key
      ENV['FIERI_KEY']
    end
  end
end
