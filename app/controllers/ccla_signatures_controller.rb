class CclaSignaturesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_linked_github_account!, only: [:new, :create, :update]
  before_filter :find_and_authorize_ccla_signature!, only: [:show, :update]

  #
  # GET /ccla-signatures/:id
  #
  # Show a single signature.
  #
  def show
    authorize! @ccla_signature
  end

  #
  # GET /ccla-signatures/new
  #
  # Show the form for creating a new CCLA signature.
  #
  def new
    @ccla_signature = CclaSignature.new(user: current_user, organization: Organization.new)

    # Load default CCLA text
    @ccla_signature.ccla = Ccla.latest
  end

  #
  # POST /ccla-signatures
  #
  # Create a new Organization and CCLA signature and assign
  # the current user as the Organization admin.
  #
  def create
    @ccla_signature = CclaSignature.new(ccla_signature_params)

    if @ccla_signature.save!
      if Supermarket::Config.cla_signature_notification_email.present?
        ClaSignatureMailer.deliver_notification(@ccla_signature)
      end

      @contributor = Contributor.create(user: @ccla_signature.user,
        organization: @ccla_signature.organization, admin: true)

      redirect_to @ccla_signature, notice: "Successfully signed CCLA for #{@ccla_signature.organization.name}."
    else
      render 'new'
    end
  end

  #
  # PATCH /ccla-signatures/:id
  #
  # Updates a CCLA signature and associated Organization.
  #
  def update
    if @ccla_signature.update_attributes(ccla_signature_params)
      redirect_to @ccla_signature, notice: "Successfully updated CCLA for #{@ccla_signature.organization.name}."
    else
      render 'show'
    end
  end

  private

  def ccla_signature_params
    params.require(:ccla_signature).permit(
      :user_id,
      :agreement,
      :ccla_id,
      organization_attributes: [
        :name,
        :address_line_1,
        :address_line_2,
        :city,
        :state,
        :zip,
        :country
      ]
    )
  end

  #
  # Redirect the user to their profile page if they do not have any linked
  # GitHub accounts with the notice to instruct them to link a GitHub account
  # before signing an CCLA.
  #
  def require_linked_github_account!
    if !current_user.linked_github_account?
      store_location_for current_user, request.path

      redirect_to current_user,
        notice: t('ccla_signature.requires_linked_github')
    end
  end

  def find_and_authorize_ccla_signature!
    @ccla_signature = CclaSignature.find(params[:id])
    authorize! @ccla_signature
  end
end
