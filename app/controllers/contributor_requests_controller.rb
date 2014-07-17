class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

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
  # @todo Implement this.
  # @note This is an _unsafe_ GET.
  #
  # Accepts the given request to join the organization which holds the given
  # CCLA Signature.
  #
  def accept
    redirect_to root_url
  end

  #
  # GET /ccla-signatures/:ccla_signature_id/contributor_requests/:id/decline
  #
  # @todo Implement this.
  # @note This is an _unsafe_ GET.
  #
  # Declines the given request to join the organization which holds the given
  # CCLA Signature.
  #
  def decline
    redirect_to root_url
  end
end
