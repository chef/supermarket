class CookbookVersionsController < ApplicationController
  def download
    cookbook = Cookbook.with_name(params[:cookbook_id]).first!
    version = cookbook.get_version!(params[:version])
    CookbookVersion.increment_counter(:download_count, version.id)
    Cookbook.increment_counter(:download_count, cookbook.id)

    redirect_to version.tarball.url
  end
end
