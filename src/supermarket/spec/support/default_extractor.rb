class DefaultExtractor < Extractor::Base
  def first_name
    split_name.first
  end

  def last_name
    split_name.last
  end

  def uid
    auth['uid']
  end

  def username
    auth['info']['username']
  end

  def email
    auth['info']['email']
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
