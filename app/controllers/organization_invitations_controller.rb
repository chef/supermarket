class OrganizationInvitationsController < ApplicationController
  before_filter :find_organization


  #
  # GET /organizations/:organization_id/invitations
  #
  # Lists all invitations and current CCLA contributors.
  #
  def index
    @pending_invitations = @organization.invitations.pending
    @declined_invitations = @organization.invitations.declined
    @contributors = @organization.contributors
    @invitation = Invitation.new(organization: @organization)

    authorize! @invitation
  end


  #
  # POST /organizations/:organization_id/invitations
  #
  # Creates and delivers a new invitation for a specific
  # organization.
  #
  def create
    @invitation = @organization.invitations.new(invitation_params)

    authorize! @invitation

    if @invitation.save
      InvitationMailer.deliver_invitation(@invitation)

      redirect_to organization_invitations_path(@organization),
        notice: "Invited #{@invitation.email} to #{@organization.name}"
    else
      render 'index'
    end
  end

  #
  # PATCH /organizations/:organization_id/invitations/:token
  #
  # Updates an invitation.
  #
  def update
    @invitation = Invitation.find_by(token: params[:id])

    authorize! @invitation

    @invitation.update_attributes(invitation_params)

    head 204
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :admin)
  end

  def find_organization
    @organization = current_user.organizations.find(params[:organization_id])
  end
end
