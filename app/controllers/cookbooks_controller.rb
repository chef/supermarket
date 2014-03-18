class CookbooksController < ApplicationController
  #
  # TODO: Document this
  #
  def index
    @cookbooks = Cookbook.all

    if ['updated_at', 'created_at'].include?(params[:order])
      @cookbooks = Cookbook.order("#{params[:order]} DESC")
    end

    respond_to do |format|
      format.atom
      format.html
    end
  end

  #
  # TODO: Document this
  #
  def directory
    @recently_updated_cookbooks = Cookbook.order('updated_at DESC').limit(3)
    @recently_created_cookbooks = Cookbook.order('created_at DESC').limit(3)
  end
end
