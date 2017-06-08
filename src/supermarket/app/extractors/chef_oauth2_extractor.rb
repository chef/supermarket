class ChefOauth2Extractor < Extractor::Base
  # @see Extractor::Base#first_name
  def first_name
    auth['info']['first_name']
  end

  # @see Extractor::Base#last_name
  def last_name
    auth['info']['last_name']
  end

  # @see Extractor::Base#email
  def email
    auth['info']['email']
  end

  # @see Extractor::Base#username
  def username
    auth['info']['username']
  end

  # @see Extractor::Base#uid
  def uid
    auth['uid']
  end

  # @see Extractor::Base#oauth_token
  def oauth_token
    auth['credentials']['token']
  end

  #
  # The time at which the provided OAuth token expires
  #
  # @return [Time]
  #
  def oauth_expires
    Time.zone.at(auth['credentials']['expires_at'])
  end

  #
  # The token to be used to refresh this user's OAuth token
  #
  # @return [String]
  #
  def oauth_refresh_token
    auth['credentials']['refresh_token']
  end

  #
  # The public_key for Chef server
  #
  def public_key
    auth['info']['public_key']
  end
end
