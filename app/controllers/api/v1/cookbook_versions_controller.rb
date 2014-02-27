class Api::V1::CookbookVersionsController < Api::V1Controller
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
end
