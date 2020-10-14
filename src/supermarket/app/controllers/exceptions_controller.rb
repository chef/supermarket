class ExceptionsController < ApplicationController
  #
  # The default failure application.
  #
  def show
    template = if template_exists?(status_code, "exceptions")
                 "exceptions/#{status_code}"
               else
                 "exceptions/500"
               end

    respond_to do |format|
      format.html { render template: template, status: status_code }
      format.json do
        render json: { message: message }, status: status_code
      end
    end
  end

  protected

  #
  # The Rack status code for the error.
  #
  # @return [Integer]
  #
  def status_code
    wrapped_exception.status_code.to_i
  end

  #
  # The message for the error.
  #
  # @return [String]
  #
  def message
    original_exception.message
  end

  private

  #
  # An exception wrapper to perform, among other things, backtrace cleaning
  #
  # @return [ActionDispatch::ExceptionWrapper]
  #
  def wrapped_exception
    @wrapped_exception ||= ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, original_exception)
  end

  def backtrace_cleaner
    request.env["action_dispatch.backtrace_cleaner"]
  end

  def original_exception
    request.env["action_dispatch.exception"]
  end
end
