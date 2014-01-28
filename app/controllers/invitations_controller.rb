class InvitationsController < ApplicationController
  before_filter :find_invitation
  before_filter :store_location_then_authenticate_user!

  def show
    @organization = @invitation.organization
  end

  def update
    @contributor = Contributor.create!(
      organization: @invitation.organization,
      user: current_user,
      admin: @invitation.admin
    )

    @invitation.accept
    redirect_to current_user, notice: "Successfully joined
      #{@contributor.organization.name}"
  end

  def destroy
    @invitation.decline
    redirect_to current_user, notice: "Declined invitation to join
      #{@invitation.organization.name}"
  end

  private

  def find_invitation
    @invitation = Invitation.find_by(token: params[:id])
  end

  def store_location_then_authenticate_user!
    store_location!
    authenticate_user!
  end
end
