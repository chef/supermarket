class Api::V1Controller < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  private

  #
  # Render the error message with a status of 404.
  #
  def render_404
    render json: error_message, status: 404
  end

  #
  # The error message for when a resources was not found.
  #
  def error_message
    {
      error_messages: ['Resource does not exist'],
      error_code: 'NOT_FOUND'
    }
  end
end
