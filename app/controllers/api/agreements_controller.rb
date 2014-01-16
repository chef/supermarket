class Api::AgreementsController < ApiController
  doorkeeper_for :all

  def show
    @account = Account.find_by(provider: 'github', username: params[:github_username])
    @user = @account.user

    render json: { signed_agreement: @user.signed_icla? || @user.signed_ccla? }
  end
end
