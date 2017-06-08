module Fieri
  class ApplicationController < ActionController::Base
    rescue_from ActionController::ParameterMissing, with: :param_missing_error

    private

    def param_missing_error(exception)
      render status: 400, json: { status: 'error',
                                  message: exception.message }
    end
  end
end
