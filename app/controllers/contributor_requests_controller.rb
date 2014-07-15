class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    ccla_signature = CclaSignature.
      includes(:organization).
      find(params[:ccla_signature_id])
    organization = ccla_signature.organization

    contributor_request = ContributorRequest.new(
      user: current_user,
      organization: organization,
      ccla_signature: ccla_signature
    )

    authorize! contributor_request

    contributor_request.save!

    ContributorRequestNotifier.perform_async(contributor_request.id)

    redirect_to :back
  end

  def accept
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    authorize! contributor_request

    ccla_signature = contributor_request.ccla_signature

    if contributor_request.pending?
      organization = contributor_request.organization

      if contributor_request.accept
        destination = contributors_ccla_signature_path(ccla_signature)
        username = contributor_request.user.username
        organization_name = contributor_request.organization.name

        ContributorRequestMailer.delay.request_accepted_email(contributor_request)

        notice = t(
          'contributor_requests.accept.success',
          username: username,
          organization: organization_name
        )

        redirect_to destination, notice: notice
      else
        # TODO: gracefully handle a beaten-to-the-punch scenario
      end
    else
      destination = contributors_ccla_signature_path(ccla_signature)
      username = contributor_request.user.username
      organization_name = contributor_request.organization.name

      if contributor_request.accepted?
        notice = t(
          'contributor_requests.accept.success',
          username: username,
          organization: organization_name
        )
      else
        notice = t(
          'contributor_requests.already.declined',
          username: username,
          organization: organization_name
        )
      end

      redirect_to destination, notice: notice
    end
  end

  def decline
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    authorize! contributor_request

    ccla_signature = contributor_request.ccla_signature

    destination = contributors_ccla_signature_path(ccla_signature)
    username = contributor_request.user.username
    organization_name = contributor_request.organization.name

    if contributor_request.pending?
      if contributor_request.decline
        ContributorRequestMailer.delay.request_declined_email(contributor_request)

        notice = t(
          'contributor_requests.decline.success',
          username: username,
          organization: organization_name
        )
      else
        # TODO: gracefully handle a beaten-to-the-punch scenario
      end
    else
      if contributor_request.declined?
        notice = t(
          'contributor_requests.decline.success',
          username: username,
          organization: organization_name
        )
      else
        notice = t(
          'contributor_requests.already.accepted',
          username: username,
          organization: organization_name
        )
      end
    end

    redirect_to destination, notice: notice
  end
end
