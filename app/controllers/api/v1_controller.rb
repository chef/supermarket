class Api::V1Controller < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  skip_before_action :verify_authenticity_token

  private

  #
  # Render the error message with a status of 404 and a message letting the
  # user know the resource does not exist.
  #
  def render_404
    error(
      {
        error_messages: [t('api.error_messages.not_found')],
        error_code: t('api.error_codes.not_found')
      },
      404
    )
  end

  #
  # Render not authorized.
  #
  # @param messages [Array<String>] the error messages
  #
  def render_not_authorized(messages)
    error(
      {
        error_code: t('api.error_codes.unauthorized'),
        error_messages: messages
      },
      401
    )
  end

  #
  # Renders an JSON body with an error and a header with a given status.
  #
  def error(body, status = 400)
    render json: body, status: status
  end
end
