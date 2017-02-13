class Api::V1::ToolsController < Api::V1Controller
  before_action :init_params, except: [:show]

  #
  # GET /api/v1/tools
  #
  # Return all Tools. Defaults to 10 at a time, starting at the first
  # Tool when sorted alphabetically. The max number of Tools that can be
  # returned is set by an environment variable API_ITEM_LIMIT. If the limit is
  # not set or set to an non-integer value, the default is 100.
  #
  # Pass in the start and items params to specify the index at which to start
  # and how many to return. You can pass in an order param to specify how
  # you'd like the the collection ordered. Possible values are
  # recently_added.
  #
  # @example
  #   GET /api/v1/tools?start=5&items=15
  #   GET /api/v1/tools?order=recently_added
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

  #
  # GET /api/v1/tools-search?q=QUERY
  #
  # Return tools with a name that contains the specified query.
  #
  # Parameters
  # - +q+ parameter for textual searches of tool name or description
  # - +type+ parameter to filter results to a single tool type
  # - +order+ order of the results, defaults to alphabetically by name
  #           options: recently_added (reverse chronological)
  # - +start+ what index to start the results list, defaults to 0
  # - +items+ how many items to return from the +start+ index, defaults to 10,
  #           with an upper limit default of 100, to change upper limit on items
  #           set API_ITEM_LIMIT environment variable.
  #
  # @example
  #   GET /api/v1/tools-search?q=berkshelf
  #   GET /api/v1/tools-search?q=berkshelf&start=3&items=5
  #   GET /api/v1/tools-search?type=compliance_profile&order=recently_added
  #
  def search
    @results = Tool.ordered_by(params[:order])

    if params[:q].present?
      @results = @results.search(params[:q])
    end

    if Tool::ALLOWED_TYPES.include?(params[:type])
      @results = @results.where(type: params[:type])
    end

    @results = @results.offset(@start).limit(@items)

    @total = @results.count(:all)
  end
end
