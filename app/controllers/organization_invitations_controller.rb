class OrganizationInvitationsController < ApplicationController
  before_filter :find_organization

  def index
    @invitation = @organization.invitations.new
  end

  def create
    @invitation = @organization.invitations.new(inviation_params)

    if @invitation.save
      redirect_to organization_invitations_path(@organization),
        notice: "Successfully invited #{@invitation.email} to #{@organization.name}"
    else
      render 'index'
    end
  end

  private
    def inviation_params
      params.require(:invitation).permit(:email, :admin)
    end

    def find_organization
      @organization = Organization.find(params[:organization_id])
    end
end
