class CclaSignaturesController < ApplicationController
  before_filter :require_valid_user!, except: [:index]

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
  # Show the form for creating a new CCLA signature
  #
  def new
    @ccla_signature = CclaSignature.new(user: current_user)
    authorize! @ccla_signature

    # Load default ICLA text
    @ccla_signature.ccla = Ccla.first

    # Prepopulate any fields we can from the User object
    @ccla_signature.email = current_user.primary_email.try(:email)
  end

  #
  # POST /ccla-signatures
  #
  # Create a new CCLA signature
  #
  def create
    @ccla_signature = CclaSignature.new(ccla_signature_params)
    authorize! @ccla_signature

    if @ccla_signature.save
      redirect_to @ccla_signature
    else
      render 'new'
    end
  end

  private
    def ccla_signature_params
      params.require(:ccla_signature).permit(
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
        :ccla_id,
      )
    end
end
