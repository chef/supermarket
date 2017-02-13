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

  #
  # This creates instance variables for +start+ and +items+, which are shared
  # between the index and search methods. Also +order+ which is for ordering.
  #
  def init_params
    @start = params.fetch(:start, 0).to_i
    @items = [params.fetch(:items, 10).to_i, item_limit].min

    if @start < 0 || @items < 0
      return error(
        error_code: t('api.error_codes.invalid_data'),
        error_messages: [t('api.error_messages.negative_parameter',
                           start: params.fetch(:start, 'not provided'),
                           items: params.fetch(:items, 'not provided'))]
      )
    end

    @order = params.fetch(:order, 'name ASC').to_s
  end

  #
  # Returns the configured limit for number of items in an API request
  # Inteded to wrap the mechanism by which the limit is configured
  #
  def item_limit
    configured_limit = ENV['API_ITEM_LIMIT'].to_i
    if configured_limit > 0
      configured_limit
    else
      100
    end
  end
end
