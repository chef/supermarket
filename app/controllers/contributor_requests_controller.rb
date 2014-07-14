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

    contributor_request = ContributorRequest.create!(
      user_id: current_user.id,
      organization_id: organization.id,
      ccla_signature_id: ccla_signature.id
    )

    ContributorRequestNotifier.perform_async(contributor_request.id)

    redirect_to :back
  end

  def accept
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    ccla_signature = contributor_request.ccla_signature

    if contributor_request.presiding_admins.include?(current_user)
      destination = contributors_ccla_signature_path(ccla_signature)
      username = contributor_request.user.username
      organization_name = contributor_request.organization.name

      notice = t(
        'contributor_requests.accept.success',
        username: username,
        organization: organization_name
      )

      redirect_to destination, notice: notice
    else
      raise NotAuthorizedError
    end
  end

  def decline
  end
end
