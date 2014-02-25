class Api::V1::CookbooksController < ApplicationController

  def index
    @start = params.fetch(:start, 0).to_i
    @items = [params.fetch(:items, 10).to_i, 100].min
    @total = Cookbook.count
    @cookbooks = Cookbook.all.order('name ASC').limit(@items).offset(@start)
  end

end
