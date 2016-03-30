class ExceptionsController < ApplicationController
  # Expose helper methods in the view
  helper_method :exception, :backtrace, :status_code

  #
  # The default failure application.
  #
  def show
    template = if template_exists?(status_code, 'exceptions')
                 "exceptions/#{status_code}"
               else
                 'exceptions/500'
               end

    respond_to do |format|
      format.html { render template: template, status: status_code }
      format.json do
        render json: { message: exception.message }, status: status_code
      end
    end
  end

  protected

  #
  # The application backtrace from the exception.
  #
  # @return [Array<String>]
  #
  def backtrace
    wrapper.application_trace
  end

  #
  # The exception that was raised.
  #
  # @return [~Exception]
  #
  def exception
    env['action_dispatch.exception']
  end

  #
  # The Rack status code for the error.
  #
  # @return [Integer]
  #
  def status_code
    wrapper.status_code.to_i
  end

  private

  #
  # The exception wrapper.
  #
  # @return [ActionDispatch::ExceptionWrapper]
  #
  def wrapper
    @wrapper ||= ActionDispatch::ExceptionWrapper.new(env, exception)
  end
end
