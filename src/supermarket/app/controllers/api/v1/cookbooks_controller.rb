class Api::V1::CookbooksController < Api::V1Controller
  before_action :init_params, only: [:index, :search]
  before_action :assign_cookbook, only: [:show, :contingent]

  #
  # GET /api/v1/cookbooks
  #
  # Return all Cookbooks. Defaults to 10 at a time, starting at the first
  # Cookbook when sorted alphabetically. The max number of Cookbooks that can be
  # returned is set by an environment variable API_ITEM_LIMIT. If the limit is
  # not set or set to an non-integer value, the default is 100.
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
  #   GET /api/v1/cookbooks?platforms[]=debian
  #
  def index
    @total = Cookbook.count
    @cookbooks = Cookbook.paginated_with_owner_and_versions(order: @order, limit: @items, start: @start)

    if params[:user]
      @cookbooks = @cookbooks.owned_by(params[:user])
    end

    if params[:platforms].present? && params[:platforms][0].present?
      @cookbooks = @cookbooks.filter_platforms(params[:platforms])
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
  # defaults to 0. Items defaults to 10. Items has an upper limit default of 100
  # which can be changed by setting an environment variable API_ITEM_LIMIT.
  #
  # @example
  #   GET /api/v1/search?q=redis
  #   GET /api/v1/search?q=redis&start=3&items=5
  #

  def search
    @results = Cookbook.search(
      params.fetch(:q, nil)
    ).offset(@start).limit(@items)

    @total = Cookbook.count
  end

  #
  # GET /api/v1/cookbooks/:cookbook/contingent
  #
  # Returns cookbooks that are contingent upon the specified cookbook. If there
  # are none, returns an empty array. If the specified cookbook can't be found,
  # returns a 404.
  #
  # @example
  #   GET /api/v1/cookbooks/apt/contingent
  #
  def contingent
    @contingents = @cookbook.contingents
  end

  private

  def assign_cookbook
    @cookbook = Cookbook
      .with_name(params[:cookbook])
      .includes(:cookbook_versions)
      .first!
  end
end
