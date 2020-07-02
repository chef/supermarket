module Fieri
  class ApplicationController < ActionController::Base
    rescue_from ActionController::ParameterMissing, with: :param_missing_error

    private

    def param_missing_error(exception)
      error = {
        status: "error",
        message: exception.message,
      }
      render status: :bad_request, json: error
    end
  end
end
