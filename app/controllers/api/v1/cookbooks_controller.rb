class Api::V1::CookbooksController < Api::V1Controller
  before_filter :init_params

  #
  # GET /api/v1/cookbooks
  #
  # Return all Cookbooks. Defaults to 10 at a time, starting at the first
  # Cookbook when sorted alphabetically. The max number of Cookbooks that can be
  # returned is 100.
  #
  # Pass in the start and items params to specify the index at which to start
  # and how many to return.
  #
  # @example
  #   GET /api/v1/cookbooks?start=5&items=15
  #
  def index
    @total = Cookbook.count
    @cookbooks = Cookbook.order('name ASC').limit(@items).offset(@start)
  end

  #
  # GET /api/v1/cookbooks/:cookbook
  #
  # Return the specified cookbook. If it does not exist, return a 404.
  #
  # @example
  #   GET /api/v1/cookbooks/redis
  #
  def show
    @cookbook = Cookbook.with_name(params[:cookbook]).first!
    @latest_cookbook_version_url = api_v1_cookbook_version_url(
      @cookbook, @cookbook.latest_cookbook_version
    )

    @cookbook_versions_urls = @cookbook.cookbook_versions.map do |version|
      api_v1_cookbook_version_url(@cookbook, version)
    end
  end

  #
  # GET /api/v1/search?q=QUERY
  #
  # Return cookbooks with a name that contains the specified query. Takes the
  # +q+ parameter for the query. It also handles the start and items parameters
  # for specify where to start the search and how many items to return. Start
  # defaults to 0. Items defaults to 10. Items has an upper limit of 100.
  #
  # @example
  #   GET /api/v1/search?q=redis
  #   GET /api/v1/search?q=redis&start=3&items=5
  #
  def search
    @results = Cookbook.search(
      params.fetch(:q, nil)
    ).offset(@start).limit(@items)
  end

  private

  #
  # This creates instance variables for +start+ and +items+, which are shared
  # between the index and search methods.
  #
  def init_params
    @start = params.fetch(:start, 0).to_i
    @items = [params.fetch(:items, 10).to_i, 100].min
  end
end
