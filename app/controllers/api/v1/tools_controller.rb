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
  # Return tools with a name that contains the specified query. Takes the +q+
  # parameter for the request. It also handles the start and items parameters
  # for specifying where to start the search and how many items to return. Start
  # defaults to 0. Items defaults to 10. Items has an upper limit of 100.
  #
  # @example
  #   GET /api/v1/tools-search?q=berkshelf
  #   GET /api/v1/tools-search?q=berkshelf&start=3&items=5
  #
  def search
    @results = Tool.search(
      params.fetch(:q, nil)
    ).offset(@start).limit(@items)

    @total = @results.count(:all)
  end
end
