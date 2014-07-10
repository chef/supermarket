class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    redirect_to :back
  end
end
