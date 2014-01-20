class InvitationsController < ApplicationController
  before_filter :find_invitation
  before_filter :require_user!

  def show
    @organization = @invitation.organization
  end

  def update
    @organization_user = OrganizationUser.create!(
      organization: @invitation.organization,
      user: current_user,
      admin: @invitation.admin
    )

    @invitation.accept
    redirect_to current_user, notice: "Successfully joined
      #{@organization_user.organization.name}"
  end

  def destroy
    @invitation.decline
    redirect_to current_user, notice: "Successfully declined
      invitation to #{@invitation.organization.name}"
  end

  rescue_from NotAuthenticatedError do |error|
    store_location!
    redirect_to sign_in_path
  end

  private
    def find_invitation
      @invitation = Invitation.find_by(token: params[:id])
    end

end
