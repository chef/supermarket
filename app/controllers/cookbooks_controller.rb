class CookbooksController < ApplicationController
  def index
    @recently_updated_cookbooks = Cookbook.recently_updated
  end
end
