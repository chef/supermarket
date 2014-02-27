class Api::V1::CookbookVersionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  #
  # GET /api/v1/cookbooks/:cookbook/versions/:version
  #
  # Return a specific CookbookVersion. Returns a 404 if the +Cookbook+ or
  # +CookbookVersion+ does not exist. The version must be passed in with
  # underscores in place of periods.
  #
  # @example
  #   GET /api/v1/cookbooks/redis/versions/1_1_0
  #
  def show
    @cookbook = Cookbook.find_by!(name: params[:cookbook])
    @cookbook_version = @cookbook.get_version!(params[:version])
  end

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
