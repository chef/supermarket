class CclaSignaturesController < ApplicationController
  before_filter :require_user!

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
    @ccla_signature = CclaSignature.new

    # Load default ICLA text
    @ccla_signature.ccla = Ccla.latest

    # Prepopulate any fields we can from the User object
    @ccla_signature.email = current_user.primary_email.try(:email)
  end

  #
  # POST /ccla-signatures
  #
  # Create a new Organization and CCLA signature and assign
  # the current user as the Organization admin.
  #
  def create
    @organization      = Organization.new(name: ccla_signature_params[:company])
    @ccla_signature    = @organization.build_ccla_signature(
      ccla_signature_params.merge(user_id: current_user.id))
    @organization_user = @organization.organization_users.new(user: current_user, admin: true)

    begin
      ActiveRecord::Base.transaction do
        @ccla_signature.save!
        @organization.save!
        @organization_user.save!
      end

      redirect_to @ccla_signature, notice: "Successfully signed CCLA for #{@organization.name}."

    rescue ActiveRecord::RecordInvalid => invald
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
