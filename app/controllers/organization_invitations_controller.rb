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
    invalid_invitations = []

    invitations_params[:emails].split(',').each do |email|
      email = email.strip
      invitation = @organization.invitations.new(
        email: email,
        admin: invitations_params[:admin]
      )

      if invitation.save
        InvitationMailer.delay.invitation_email(invitation)
      else
        invalid_invitations << invitation
      end
    end

    if invalid_invitations.empty?
      redirect_to organization_invitations_path(@organization),
                  notice: t('organization_invitations.invites.success')
    else
      redirect_to organization_invitations_path(@organization), flash: {
        warning: t('organization_invitations.invites.warning',
                   invites: invalid_invitations.map(&:email).join(', '))
      }
    end
  end

  #
  # PATCH /organizations/:organization_id/invitations/:id
  #
  # Updates an invitation.
  #
  def update
    @invitation = Invitation.with_token!(params[:id])
    @invitation.update_attributes(invitation_admin_params)

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

    redirect_to(
      :back,
      notice: t('organization_invitations.resend', email: @invitation.email)
    )
  end

  #
  # DELETE /organizations/:organization_id/invitations/:id/resend
  #
  # Revokes an invitation.
  #
  def revoke
    @invitation = Invitation.with_token!(params[:id])
    @invitation.destroy

    redirect_to(
      :back,
      notice: t('organization_invitations.revoke', email: @invitation.email)
    )
  end

  private

  def invitation_admin_params
    params.require(:invitation).permit(:admin)
  end

  def invitations_params
    params.require(:invitations).permit(:emails, :admin)
  end

  def find_and_authorize_organization!
    @organization = Organization.find(params[:organization_id])
    authorize! @organization, :manage_contributors?
  end
end
