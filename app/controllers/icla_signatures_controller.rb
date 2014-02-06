class IclaSignaturesController < ApplicationController
  before_filter :redirect_if_signed!, only: [:new, :create]
  before_filter :authenticate_user!, except: [:index]
  before_filter :require_linked_github_account!, only: [:new, :create]
  before_filter :find_and_authorize_icla_signature!, only: [:show]

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

  private

  def icla_signature_params
    params.require(:icla_signature).permit(
      :user_id,
      :agreement,
      :icla_id,
      user_attributes: [
        :signing_icla,
        :phone,
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
