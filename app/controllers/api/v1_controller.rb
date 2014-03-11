class Api::V1Controller < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  skip_before_action :verify_authenticity_token

  private

  #
  # Render the error message with a status of 404 and a message letting the
  # user know the resource does not exist.
  #
  def render_404
    render(
      json: {
        error_messages: ['Resource does not exist'],
        error_code: 'NOT_FOUND'
      },
      status: 404
    )
  end
end
