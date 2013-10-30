class DefaultExtractor < Extractor::Base
  def first_name
    auth['info']['name'].first
  end

  def last_name
    auth['info']['name'].last
  end

  def uid
    auth['uid']
  end

  def username
    auth['info']['username']
  end

  def oauth_token
    auth['credentials']['token']
  end

  def oauth_secret
    auth['credentials']['secret']
  end

  def oauth_expires
    auth['credentials']['expires']
  end
end
