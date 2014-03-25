class CookbooksController < ApplicationController
  before_filter :assign_categories

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
        where('lower(categories.name) = ?', params[:category].downcase)
    else
      @cookbooks = Cookbook.includes(:latest_cookbook_version)
    end

    if params[:q]
      @cookbooks = @cookbooks.search(params[:q])
    end

    case params[:order]
    when 'recently_updated'
      @cookbooks = @cookbooks.order('updated_at DESC')
    when 'recently_created'
      @cookbooks = @cookbooks.order('created_at DESC')
    else
      @cookbooks = @cookbooks.order('name ASC')
    end

    @cookbooks = @cookbooks.page(params[:page]).per(20)

    respond_to do |format|
      format.atom
      format.html
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
      order('updated_at DESC').
      limit(3)
    @recently_added_cookbooks = Cookbook.
      includes(:latest_cookbook_version).
      order('created_at DESC').
      limit(3)
  end

  #
  # GET /cookbooks/:id
  #
  # @todo Provide real maintainer and collaborator records to the view once
  # oc-id is in place
  #
  # Displays a cookbook.
  #
  def show
    @cookbook = Cookbook.with_name(params[:id]).first!
    @latest_version = @cookbook.latest_cookbook_version
    @cookbook_versions = @cookbook.cookbook_versions
    @maintainer = User.first
    @collaborators = [User.first]
    @supported_platforms = @cookbook.supported_platforms
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

  private

  def assign_categories
    @categories ||= Category.all
  end
end
