class Api::V1::HealthController < Api::V1Controller
  #
  # GET /api/v1/health
  #
  # An overview of system health
  #
  def show
    @expired_oauth_tokens = Account.
      for('chef_oauth2').
        where('oauth_expires < ?', Time.now).
        count
  end
end
