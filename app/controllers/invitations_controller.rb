class InvitationsController < ApplicationController
  before_filter :find_invitation
  before_filter :store_location_then_authenticate_user!
  before_filter :require_linked_github_account!, only: [:accept]
  include ApplicationHelper

  def show
    @organization = @invitation.organization
  end

  def accept
    @contributor = Contributor.new(
      organization: @invitation.organization,
      user: current_user,
      admin: @invitation.admin
    )

    if @contributor.save
      @invitation.accept

      Curry::CommitAuthorVerificationWorker.perform_async(current_user.id)

      redirect_to current_user, notice: "Successfully joined
        #{@contributor.organization.name}"
    else
      redirect_to current_user, alert: "You have already signed
        #{posessivize(@invitation.organization.name)} CCLA, please sign in as a
        different user to accept or if this invitation was sent
        in error no action is required."
    end
  end

  def decline
    @invitation.decline
    redirect_to current_user, notice: "Declined invitation to join
      #{@invitation.organization.name}"
  end

  private

  def find_invitation
    @invitation = Invitation.with_token!(params[:id])
  end

  def store_location_then_authenticate_user!
    store_location!
    authenticate_user!
  end
end
