class InvitationsController < ApplicationController
  before_filter :find_invitation
  before_filter :store_location_then_authenticate_user!

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
      redirect_to current_user, notice: "Successfully joined
        #{@contributor.organization.name}"
    else
      redirect_to current_user, alert: "You've already signed
        #{@invitation.organization.name}'s CCLA, please sign in as a
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
