class IclaSignaturesController < ApplicationController
  before_filter :redirect_if_signed!, only: [:new, :create, :update]
  before_filter :require_valid_user!, except: [:index]

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
  # Show a single signature.
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
    authorize! @icla_signature

    # Load default ICLA text
    @icla_signature.icla = Icla.latest

    # Prepopulate any fields we can from the User object
    @icla_signature.prefix      = current_user.prefix
    @icla_signature.first_name  = current_user.first_name
    @icla_signature.middle_name = current_user.middle_name
    @icla_signature.last_name   = current_user.last_name
    @icla_signature.suffix      = current_user.suffix
    @icla_signature.email       = current_user.primary_email.try(:email)
    @icla_signature.phone       = current_user.phone
    @icla_signature.company     = current_user.company
  end

  #
  # POST /icla-signatures
  #
  # Create a new Icla signature
  #
  def create
    @icla_signature = IclaSignature.new(icla_signature_params)
    authorize! @icla_signature

    if @icla_signature.save
      redirect_to @icla_signature
    else
      render 'new'
    end
  end

  #
  # DELETE /icla-signatures
  #
  # Delete an Icla signature
  #
  def destroy
    @icla_signature = IclaSignature.find(params[:id])
    authorize! @icla_signature

    @icla_signature.destroy
    redirect_to icla_signatures_path
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
      if logged_in? && current_user.signed_icla?
        return redirect_to root_path, alert: 'You have already signed the Individual CLA!'
      end
    end
end
