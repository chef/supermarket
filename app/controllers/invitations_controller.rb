class InvitationsController < ApplicationController
  before_filter :find_invitation
  before_filter :require_valid_user!

  def show
  end

  def update
    @organization_user = OrganizationUser.create!(
      organization: @invitation.organization, user: current_user,
      admin: @invitation.admin)

    redirect_to current_user, notice: "Successfully joined
      #{@organization_user.organization}"
  end

  rescue_from NotAuthorizedError do |error|
    redirect_to sign_in_path
  end

  private
    def find_invitation
      @invitation = Invitation.find_by(token: params[:id])
    end

end
