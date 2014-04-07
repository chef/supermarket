class CookbooksController < ApplicationController
  before_filter :assign_categories
  before_filter :assign_cookbook, only: [:show, :update, :follow, :unfollow]
  before_filter :store_location_then_authenticate_user!, only: [:follow, :unfollow]

  #
  # GET /cookbooks(/categories/:category)
  #
  # Return all cookbooks. Cookbooks are sorted alphabetically by name.
  # Optionally a category can be specified to return only cookbooks for a
  # given category. Cookbooks can also be returned as an atom feed if the atom
  # format is specified.
  #
  # Pass in a query param to search for specific cookbooks
  #
  # @example
  #   GET /cookbooks?q=redis
  #
  # Pass in order params to specify a sort order.
  #
  # @example
  #   GET /cookbooks?order=recently_updated
  #
  def index
    if params[:category]
      @cookbooks = Cookbook.
        includes(:latest_cookbook_version).
        joins(:category).
        where('categories.slug = ?', params[:category])
    else
      @cookbooks = Cookbook.includes(:latest_cookbook_version)
    end

    if params[:q]
      @cookbooks = @cookbooks.search(params[:q])
    end

    order, page = params[:order], params[:page]

    @cookbooks = @cookbooks.ordered_by(order).page(page).per(20)

    respond_to do |format|
      format.html
      format.atom
    end
  end

  #
  # GET /cookbooks/directory
  #
  # Return the three most recently updated and created cookbooks.
  #
  def directory
    @recently_updated_cookbooks = Cookbook.
      includes(:latest_cookbook_version).
      ordered_by('recently_updated').
      limit(3)
    @recently_added_cookbooks = Cookbook.
      includes(:latest_cookbook_version).
      ordered_by('recently_added').
      limit(3)
    @most_downloaded_cookbooks = Cookbook.
      includes(:latest_cookbook_version).
      ordered_by('most_downloaded').
      limit(3)
    @most_followed_cookbooks = Cookbook.
      includes(:latest_cookbook_version).
      ordered_by('most_followed').
      limit(3)
  end

  #
  # GET /cookbooks/:id
  #
  # Displays a cookbook.
  #
  def show
    @latest_version = @cookbook.latest_cookbook_version
    @cookbook_versions = @cookbook.cookbook_versions
    @owner = @cookbook.owner
    @collaborators = @cookbook.collaborators
    @supported_platforms = @cookbook.supported_platforms
    @owner_collaborator = CookbookCollaborator.new cookbook: @cookbook, user: @owner

    respond_to do |format|
      format.atom
      format.html
    end
  end

  #
  # GET /cookbooks/:id/download
  #
  # Redirects to the download location for the latest version of this cookbook.
  #
  def download
    cookbook = Cookbook.with_name(params[:id]).first!
    latest_version = cookbook.latest_cookbook_version
    redirect_to cookbook_version_download_url(cookbook, latest_version)
  end

  #
  # PATCH /cookbooks/:id
  #
  # Update a the specified cookbook. This currently only supports updating the
  # cookbook's URLs. It also only returns JSON.
  #
  # NOTE: :id must be the name of the cookbook.
  #
  def update
    @cookbook.update_attributes(cookbook_urls_params)

    redirect_to @cookbook
  end

  #
  # PUT /cookbooks/:cookbook/follow
  #
  # Makes the current user follow the specified cookbook.
  #
  def follow
    @cookbook.cookbook_followers.create(user: current_user)

    redirect_to :back
  end

  #
  # DELETE /cookbooks/:cookbook/unfollow
  #
  # Makes the current user unfollow the specified cookbook.
  #
  def unfollow
    cookbook_follower = @cookbook.cookbook_followers.
      where(user: current_user).first
    cookbook_follower.try(:destroy)

    redirect_to @cookbook
  end

  private

  def assign_categories
    @categories ||= Category.all
  end

  def assign_cookbook
    @cookbook ||= Cookbook.with_name(params[:id]).first!
  end

  def store_location_then_authenticate_user!
    store_location!(cookbook_path(@cookbook))
    authenticate_user!
  end

  def cookbook_urls_params
    params.require(:cookbook).permit(:source_url, :issues_url)
  end
end
