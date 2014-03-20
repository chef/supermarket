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
      @cookbooks = Cookbook.joins(:category).
        where('lower(categories.name) = ?', params[:category].downcase)
    else
      @cookbooks = Cookbook.all
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
    @recently_updated_cookbooks = Cookbook.order('updated_at DESC').limit(3)
    @recently_added_cookbooks = Cookbook.order('created_at DESC').limit(3)
  end

  #
  # GET /cookbooks/:cookbook
  #
  def show
  end

  private

  def assign_categories
    @categories ||= Category.all
  end
end
