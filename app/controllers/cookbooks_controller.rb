class CookbooksController < ApplicationController
  def index
    @recently_updated_cookbooks = Cookbook.order(:updated_at)
    @recently_created_cookbooks = Cookbook.order(:created_at)
  end
end
