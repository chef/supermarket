class Api::V1::ToolsController < Api::V1Controller
  before_filter :init_params, except: [:show]

  #
  # GET /api/v1/tools
  #
  # Return all Tools. Defaults to 10 at a time, starting at the first
  # Tool when sorted alphabetically. The max number of Tools that can be
  # returned is 100.
  #
  # Pass in the start and items params to specify the index at which to start
  # and how many to return. You can pass in an order param to specify how
  # you'd like the the collection ordered. Possible values are
  # recently_added.
  #
  # @example
  #   GET /api/v1/cookbooks?start=5&items=15
  #   GET /api/v1/cookbooks?order=recently_added
  #
  def index
    @total = Tool.count
    @tools = Tool.index(order: @order, limit: @items, start: @start)
  end

  #
  # GET /api/v1/tools/:tool
  #
  # Return the specified tool based on the slug. If it does not exist, return a
  # 404.
  #
  # @example
  #   GET /api/v1/tools/berkshelf
  #
  def show
    @tool = Tool.find_by!(slug: params[:tool])
  end
end
