class IclaSignaturesController < ApplicationController
  before_filter :redirect_if_signed!, only: [:new, :create]
  before_filter :authenticate_user!, except: [:index, :agreement]
  before_filter :require_linked_github_account!, only: [:new, :create, :re_sign]

  #
  # GET /icla-signatures
  #
  # Displays a list of all users who have a signed ICLA.
  #
  def index
    @icla_signatures = IclaSignature.by_user.page(params[:page]).per(50)
  end

  #
  # GET /icla-signatures/:id
  #
  # Show a single ICLA signature.
  #
  def show
    @icla_signature = IclaSignature.find(params[:id])
    authorize! @icla_signature
  end

  #
  # GET /icla-signatures/new
  #
  # Show the form for creating a new ICLA signature
  #
  def new
    @icla_signature = IclaSignature.new(user: current_user)

    # Load default ICLA text
    @icla_signature.icla = Icla.latest

    # Prepopulate any fields we can from the User object
    @icla_signature.first_name = current_user.first_name
    @icla_signature.last_name = current_user.last_name
    @icla_signature.email = current_user.email
  end

  #
  # POST /icla-signatures
  #
  # Create a new ICLA signature
  #
  def create
    @icla_signature = IclaSignature.new(icla_signature_params)

    if @icla_signature.save
      if ENV['CLA_SIGNATURE_NOTIFICATION_EMAIL'].present?
        ClaSignatureMailer.delay.icla_signature_notification_email(@icla_signature)
      end

      Curry::CommitAuthorVerificationWorker.perform_async(current_user.id)

      redirect_to icla_signatures_path, notice: t('icla.successful_signature')
    else
      render 'new'
    end
  end

  #
  # POST /icla-signatures/re-sign
  #
  # Creates a new ICLA signature based on a previously signed signature.
  # Effectivly resigning the ICLA. Useful if ICLA contact information
  # needs to be updated.
  #
  def re_sign
    @icla_signature = IclaSignature.new(icla_signature_params)

    if @icla_signature.save
      redirect_to icla_signatures_path, notice: t('icla.successful_resignature')
    else
      render 'show'
    end
  end

  #
  # GET /icla-signatures/agreement
  #
  # Views the actual text of the ICLA agreement in a format that's suitable for
  # printing.
  #
  def agreement
    @cla_agreement = Icla.latest
    render layout: false
  end

  private

  def icla_signature_params
    params.require(:icla_signature).permit(
      :user_id,
      :prefix,
      :first_name,
      :middle_name,
      :last_name,
      :suffix,
      :email,
      :phone,
      :address_line_1,
      :address_line_2,
      :city,
      :state,
      :zip,
      :country,
      :agreement,
      :icla_id
    )
  end

  #
  # Redirect to the home page if the current user already has a signed ICLA.
  #
  def redirect_if_signed!
    if signed_in? && current_user.signed_icla?
      return redirect_to root_path, alert: t('icla.duplicate_signature')
    end
  end
end
