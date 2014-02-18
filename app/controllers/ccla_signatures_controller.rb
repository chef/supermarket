class CclaSignaturesController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :require_linked_github_account!, only: [:new, :create, :re_sign]

  #
  # GET /icla-signatures
  #
  # Displays a list of all users who have a signed ICLA.
  #
  def index
    @ccla_signatures = CclaSignature.by_organization
  end

  #
  # GET /ccla-signatures/:id
  #
  # Show a single signature.
  #
  def show
    @ccla_signature = CclaSignature.find(params[:id])
    authorize! @ccla_signature
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

    if @ccla_signature.sign!
      if Supermarket::Config.cla_signature_notification_email.present?
        ClaSignatureMailer.deliver_notification(@ccla_signature)
      end

      Curry::CommitAuthorVerificationWorker.perform_async(current_user.id)

      redirect_to @ccla_signature, notice: 'Successfully signed CCLA.'
    else
      render 'new'
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

    if @ccla_signature.save
      redirect_to @ccla_signature, notice: 'Successfully re-signed CCLA.'
    else
      render 'show'
    end
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

  #
  # Redirect the user to their profile page if they do not have any linked
  # GitHub accounts with the notice to instruct them to link a GitHub account
  # before signing an CCLA.
  #
  def require_linked_github_account!
    if !current_user.linked_github_account?
      store_location_for current_user, request.path

      redirect_to link_github_profile_path,
        notice: t('ccla_signature.requires_linked_github')
    end
  end
end
