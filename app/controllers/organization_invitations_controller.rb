class OrganizationInvitationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_and_authorize_organization!

  #
  # GET /organizations/:organization_id/invitations
  #
  # Lists all invitations and current CCLA contributors.
  #
  def index
    @pending_invitations = @organization.invitations.pending
    @declined_invitations = @organization.invitations.declined
    @contributors = @organization.contributors
  end

  #
  # POST /organizations/:organization_id/invitations
  #
  # Creates and delivers a new invitation for a specific
  # organization.
  #
  def create
    invitation_params[:emails].split(',').each do |email|
      @invitation = @organization.invitations.new(
        email: email,
        admin: invitation_params[:admin]
      )

      @invitation.save
      InvitationMailer.delay.invitation_email(@invitation)
    end

    redirect_to organization_invitations_path(@organization), notice: 'Successfully sent invitations.'
  end

  #
  # PATCH /organizations/:organization_id/invitations/:id
  #
  # Updates an invitation.
  #
  def update
    @invitation = Invitation.with_token!(params[:id])
    @invitation.update_attributes(invitation_params)

    head 204
  end

  #
  # PATCH /organizations/:organization_id/invitations/:id/resend
  #
  # Resends email for a given invitation.
  #
  def resend
    @invitation = Invitation.with_token!(params[:id])
    InvitationMailer.delay.invitation_email(@invitation)

    redirect_to :back, notice: "Successfully resent
      invitation for #{@invitation.email}"
  end

  #
  # DELETE /organizations/:organization_id/invitations/:id/resend
  #
  # Revokes an invitation.
  #
  def revoke
    @invitation = Invitation.with_token!(params[:id])
    @invitation.destroy

    redirect_to :back, notice: "Successfully revoked
      invitation for #{@invitation.email}"
  end

  private

  def invitation_params
    params.require(:invitations).permit(:emails, :admin)
  end

  def find_and_authorize_organization!
    @organization = current_user.organizations.find(params[:organization_id])
    authorize! @organization, :manage_invitations?
  end
end
