class Api::V1::CookbooksController < Api::V1Controller
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
    @start = params.fetch(:start, 0).to_i
    @items = [params.fetch(:items, 10).to_i, 100].min
    @total = Cookbook.count
    @cookbooks = Cookbook.all.order('name ASC').limit(@items).offset(@start)
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
    @cookbook = Cookbook.find_by!(name: params[:cookbook])
  end
end
