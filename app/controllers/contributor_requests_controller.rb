class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

  #
  # POST /ccla-signatures/:ccla_signature_id
  #
  # Issues a request on behalf of the current user to join the +Organization+
  # to which the given CCLA Signature belongs.
  #
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

  #
  # GET /ccla-signatures/:ccla_signature_id/decline/:id
  #
  # Accepts the +ContributorRequest+ identified by the given +id+
  #
  def accept
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    authorize! contributor_request

    ccla_signature = contributor_request.ccla_signature
    destination = contributors_ccla_signature_path(ccla_signature)

    contributor_request.accept do |transition|
      if transition.authoritative?
        ContributorRequestMailer.delay.request_accepted_email(contributor_request)
      end

      if transition.successful?
        notice = I18n.t(
          'contributor_requests.accept.success',
          username: contributor_request.user.username,
          organization: contributor_request.organization.name
        )
      else
        notice = I18n.t(
          'contributor_requests.already.declined',
          username: contributor_request.user.username,
          organization: contributor_request.organization.name
        )
      end

      redirect_to destination, notice: notice
    end
  end

  #
  # GET /ccla-signatures/:ccla_signature_id/decline/:id
  #
  # Declines the +ContributorRequest+ identified by the given +id+
  #
  def decline
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    authorize! contributor_request

    ccla_signature = contributor_request.ccla_signature
    destination = contributors_ccla_signature_path(ccla_signature)

    contributor_request.decline do |transition|
      if transition.authoritative?
        ContributorRequestMailer.delay.request_declined_email(contributor_request)
      end

      if transition.successful?
        notice = I18n.t(
          'contributor_requests.decline.success',
          username: contributor_request.user.username,
          organization: contributor_request.organization.name
        )
      else
        notice = I18n.t(
          'contributor_requests.already.accepted',
          username: contributor_request.user.username,
          organization: contributor_request.organization.name
        )
      end

      redirect_to destination, notice: notice
    end
  end
end
