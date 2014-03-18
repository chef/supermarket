class CookbooksController < ApplicationController
  #
  # GET /cookbooks
  #
  # Return all cookbooks. Cookbooks are sorted alphabetically by name.
  #
  # Pass in order params to specify a sort order.
  #
  # @example
  #   GET /cookbooks?order=updated_at
  #
  def index
    @cookbooks = Cookbook.order('name ASC')

    if ['updated_at', 'created_at'].include?(params[:order])
      @cookbooks = Cookbook.order("#{params[:order]} DESC")
    end

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
    @recently_created_cookbooks = Cookbook.order('created_at DESC').limit(3)
  end
end
