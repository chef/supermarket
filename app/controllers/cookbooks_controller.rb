class CookbooksController < ApplicationController
  def directory
    @recently_updated_cookbooks = Cookbook.order(:updated_at)
    @recently_created_cookbooks = Cookbook.order(:created_at)
  end
end
