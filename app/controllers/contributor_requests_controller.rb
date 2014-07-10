class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    ccla_signature = CclaSignature.find(params[:ccla_signature_id])

    redirect_to :back
  end
end
