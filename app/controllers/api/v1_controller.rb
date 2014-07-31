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
        error_messages: [t('api.error_messages.not_found')],
        error_code: t('api.error_codes.not_found')
      },
      status: 404
    )
  end
end
