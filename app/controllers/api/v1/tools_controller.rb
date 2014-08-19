class Api::V1::ToolsController < Api::V1Controller
  #
  # GET /api/v1/tools/:tool
  #
  # Return the specified tool. If it does not exist, return a 404.
  #
  # @example
  #   GET /api/v1/tools/berkshelf
  #
  def show
    @tool = Tool.find_by!(name: params[:tool])
  end
end
