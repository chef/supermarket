class CclaSignaturesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :agreement, :contributors]
  before_filter :require_linked_github_account!, only: [:new, :create, :re_sign]

  #
  # GET /ccla-signatures
  #
  # Displays a list of all users who have a signed CCLA.
  #
  def index
    @ccla_signatures = CclaSignature.by_organization

    if params[:q]
      @ccla_signatures = @ccla_signatures.search(params[:q])
    end

    if params[:exclude_id]
      @ccla_signatures = @ccla_signatures.where('organization_id <> ?', params[:exclude_id])
    end

    @ccla_signatures = @ccla_signatures.page(params[:page]).per(50)

    respond_to do |format|
      format.html
      format.json
    end
  end

  #
  # GET /ccla-signatures/:id
  #
  # Show a single signature.
  #
  def show
    @ccla_signature = CclaSignature.find(params[:id])
    authorize! @ccla_signature.organization, :view_cclas?
  end

  #
  # GET /ccla-signatures/new
  #
  # Show the form for creating a new CCLA signature.
  #
  def new
    @ccla_signature = CclaSignature.new(user: current_user)

    # Load default CCLA text
    @ccla_signature.ccla = Ccla.latest

    # Prepopulate any fields we can from the User object
    @ccla_signature.email = current_user.email
    @ccla_signature.first_name = current_user.first_name
    @ccla_signature.last_name = current_user.last_name
    @ccla_signature.company = current_user.company
  end

  #
  # POST /ccla-signatures
  #
  # Create a new Organization and CCLA signature and assign
  # the current user as the Organization admin.
  #
  def create
    @ccla_signature = CclaSignature.new(ccla_signature_params)

    begin
      @ccla_signature.sign!
    rescue ActiveRecord::RecordInvalid
      render 'new'
    else
      if ENV['CLA_SIGNATURE_NOTIFICATION_EMAIL'].present?
        ClaSignatureMailer.delay.ccla_signature_notification_email(@ccla_signature)
      end

      Curry::CommitAuthorVerificationWorker.perform_async(current_user.id)

      redirect_to organization_invitations_path(@ccla_signature.organization), notice: t('ccla.successful_signature')
    end
  end

  #
  # POST /ccla-signatures/re-sign
  #
  # Creates a new CCLA signature based on a previously signed signature.
  # Effectivly resigning the CCLA. Useful if CCLA contact information
  # needs to be updated.
  #
  def re_sign
    @ccla_signature = CclaSignature.new(ccla_signature_params)
    authorize! @ccla_signature.organization, :resign_ccla?

    if @ccla_signature.save
      redirect_to organization_invitations_path(@ccla_signature.organization), notice: t('ccla.successful_resignature')
    else
      render 'show'
    end
  end

  #
  # GET /ccla-signatures/agreement
  #
  # Views the actual text of the CCLA agreement in a format that's suitable for
  # printing.
  #
  def agreement
    @cla_agreement = Ccla.latest
    render layout: false
  end

  #
  # GET /ccla-signatures/:id/contributors
  #
  # Display all contributors on behalf of the CCLA organization
  #
  def contributors
    @ccla_signature = CclaSignature.find(params[:id])
  end

  private

  def ccla_signature_params
    params.require(:ccla_signature).permit(
      :prefix,
      :first_name,
      :middle_name,
      :last_name,
      :suffix,
      :email,
      :phone,
      :company,
      :address_line_1,
      :address_line_2,
      :city,
      :state,
      :zip,
      :country,
      :agreement,
      :ccla_id,
      :user_id,
      :organization_id
    )
  end
end
