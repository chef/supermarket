class IclaSignaturesController < ApplicationController
  #
  # GET /icla-signatures
  #
  # Displays a list of all users who have a signed ICLA.
  #
  def index
    @icla_signatures = IclaSignature.by_user
  end

  #
  # GET /icla-signatures/:id
  #
  # Show a single signature.
  #
  def show
    @icla_signature = IclaSignature.find(params[:id])
  end
end
