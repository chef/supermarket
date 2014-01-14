class OrganizationInvitationsController < ApplicationController
  before_filter :find_organization

  def index
    @invitations = @organization.invitations
    @invitation = Invitation.new

    authorize! @invitation
  end

  def create
    @invitation = @organization.invitations.new(invitation_params)

    authorize! @invitation

    if @invitation.save
      redirect_to organization_invitations_path(@organization),
        notice: "Invited #{@invitation.email} to #{@organization.name}"
    else
      render 'index'
    end
  end

  private
    def invitation_params
      params.require(:invitation).permit(:email, :admin)
    end

    def find_organization
      @organization = current_user.organizations.find(params[:organization_id])
    end
end
