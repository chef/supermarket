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
  # and how many to return. You can pass in an order param to specify how
  # you'd like the the collection ordered. Possible values are
  # recently_updated, recently_added, most_downloaded, most_followed. Finally,
  # you can pass in a user param to only show cookbooks that are owned by
  # a specific username.
  #
  # @example
  #   GET /api/v1/cookbooks?start=5&items=15
  #   GET /api/v1/cookbooks?order=recently_updated
  #   GET /api/v1/cookbooks?user=timmy
  #
  def index
    @total = Cookbook.count
    @cookbooks = Cookbook.index(order: @order, limit: @items, start: @start)

    if params[:user]
      @cookbooks = @cookbooks.owned_by(params[:user])
    end
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
    @cookbook = Cookbook.with_name(params[:cookbook]).
      includes(:cookbook_versions).first!
    @latest_cookbook_version_url = api_v1_cookbook_version_url(
      @cookbook, @cookbook.latest_cookbook_version
    )

    @cookbook_versions_urls = @cookbook.sorted_cookbook_versions.map do |version|
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
    @search = Cookbook.search do
      fulltext params[:q]
      paginate page: @start, per_page: @items
    end

    @results = @search.results
    @total = @search.total
  end

  private

  #
  # This creates instance variables for +start+ and +items+, which are shared
  # between the index and search methods. Also +order+ which is for ordering.
  #
  def init_params
    @start = params.fetch(:start, 0).to_i
    @items = Integer([params.fetch(:items, 10).to_i, 100].min)
    @order = params.fetch(:order, 'name ASC').to_s
  end
end
