class Api::IclaSignaturesController < Api::ApplicationController
  def index
    @icla_signatures = IclaSignature.includes(:user).order('users.last_name, users.first_name')
  end

  def show
    @icla_signature = IclaSignature.find(params[:id])
  end
end
