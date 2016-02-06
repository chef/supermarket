class ContributorRequestsController < ApplicationController
  before_action :authenticate_user!

  #
  # POST /ccla-signatures/:ccla_signature_id/contributor_requests
  #
  # Issues a request to join the organization which holds the given CCLA
  # Signature.
  #
  def create
    ccla_signature = CclaSignature.
      includes(:organization).
      find(params[:ccla_signature_id])
    organization = ccla_signature.organization

    authorize! organization, :request_to_join?

    contributor_request = ContributorRequest.new(
      user: current_user,
      organization: organization,
      ccla_signature: ccla_signature
    )

    contributor_request.save!

    ContributorRequestNotifier.perform_async(contributor_request.id)

    render partial: 'ccla_signatures/pending_approval'
  end

  #
  # GET /ccla-signatures/:ccla_signature_id/contributor_requests/:id/accept
  #
  # @note This is an _unsafe_ GET.
  #
  # Accepts the given request to join the organization which holds the given
  # CCLA Signature.
  #
  def accept
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    authorize! contributor_request

    contributor_request.accept do
      ContributorRequestMailer.delay.request_accepted_email(contributor_request)
    end

    if contributor_request.accepted?
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

    redirect_to(
      contributors_ccla_signature_path(contributor_request.ccla_signature),
      notice: notice
    )
  end

  #
  # GET /ccla-signatures/:ccla_signature_id/contributor_requests/:id/decline
  #
  # @note This is an _unsafe_ GET.
  #
  # Declines the given request to join the organization which holds the given
  # CCLA Signature.
  #
  def decline
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    authorize! contributor_request

    contributor_request.decline do
      ContributorRequestMailer.delay.request_declined_email(contributor_request)
    end

    if contributor_request.declined?
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

    redirect_to(
      contributors_ccla_signature_path(contributor_request.ccla_signature),
      notice: notice
    )
  end
end
