class InvitationsController < ApplicationController
  before_filter :find_invitation
  before_filter :require_valid_user!

  def show
  end

  def update
    @organization_user = OrganizationUser.create!(
      organization: @invitation.organization, user: current_user,
      admin: @invitation.admin)

    @invitation.accept
    redirect_to current_user, notice: "Successfully joined
      #{@organization_user.organization.name}"
  end

  def destroy
    @invitation.reject
    redirect_to current_user, notice: "Successfully rejected
      invitation to #{@invitation.organization.name}"
  end

  rescue_from NotAuthorizedError do |error|
    redirect_to sign_in_path
  end

  private
    def find_invitation
      @invitation = Invitation.find_by(token: params[:id])
    end

end
