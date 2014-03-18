class CookbooksController < ApplicationController
  #
  # GET /cookbooks/:name - NOTE: is this the right syntax?
  #
  # Displays a cookbook.
  #
  def show
    @cookbook = Cookbook.find_by(name: params[:id])
    @latest_version = @cookbook.get_version!('latest')
  end
end
