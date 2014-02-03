class IclaSignaturesController < ApplicationController
  before_filter :redirect_if_signed!, only: [:new, :create]
  before_filter :authenticate_user!, except: [:index]
  before_filter :require_linked_github_account!, only: [:new, :create, :update]
  before_filter :find_and_authorize_icla_signature!, only: [:show, :update]

  #
  # GET /icla-signatures
  #
  # Displays a list of all users who have a signed ICLA.
  #
  def index
    @icla_signatures = IclaSignature.by_user
    authorize! @icla_signatures
  end

  #
  # GET /icla-signatures/:id
  #
  # Show a single ICLA signature.
  #
  def show
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
    @icla_signature.prefix      = current_user.prefix
    @icla_signature.first_name  = current_user.first_name
    @icla_signature.middle_name = current_user.middle_name
    @icla_signature.last_name   = current_user.last_name
    @icla_signature.suffix      = current_user.suffix
    @icla_signature.email       = current_user.email
    @icla_signature.phone       = current_user.phone
    @icla_signature.company     = current_user.company
  end

  #
  # POST /icla-signatures
  #
  # Create a new ICLA signature
  #
  def create
    @icla_signature = IclaSignature.new(icla_signature_params)

    if @icla_signature.save
      if Supermarket::Config.cla_signature_notification_email.present?
        ClaSignatureMailer.deliver_notification(@icla_signature)
      end

      redirect_to @icla_signature, notice: 'Successfully signed ICLA.'
    else
      render 'new'
    end
  end

  #
  # PATCH /icla-signatures/:id
  #
  # Updates a ICLA signature.
  #
  def update
    if @icla_signature.update_attributes(icla_signature_params)
      redirect_to @icla_signature, notice: "Successfully updated your ICLA."
    else
      render 'show'
    end
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
      :company,
      :address_line_1,
      :address_line_2,
      :city,
      :state,
      :zip,
      :country,
      :agreement,
      :icla_id,
    )
  end

  #
  # Redirect to the home page if the current user already has a signed ICLA.
  #
  def redirect_if_signed!
    if signed_in? && current_user.signed_icla?
      return redirect_to root_path, alert: 'You have already signed the Individual CLA!'
    end
  end

  #
  # Redirect the user to their profile page if they do not have any linked
  # GitHub accounts with the notice to instruct them to link a GitHub account
  # before signing an ICLA.
  #
  def require_linked_github_account!
    if !current_user.linked_github_account?
      store_location_for current_user, request.path

      redirect_to current_user,
        notice: t('icla_signature.requires_linked_github')
    end
  end

  def find_and_authorize_icla_signature!
    @icla_signature = IclaSignature.find(params[:id])
    authorize! @icla_signature
  end
end
