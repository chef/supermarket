class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    ccla_signature = CclaSignature.
      includes(:organization).
      find(params[:ccla_signature_id])
    organization = ccla_signature.organization

    if organization.contributors.where(user_id: current_user.id).any?
      raise NotAuthorizedError
    end

    ContributorRequest.create!(
      user_id: current_user.id,
      organization_id: organization.id
    )

    redirect_to :back
  end
end
