class TwitterExtractor < Extractor::Base
  # @see Extractor::Base#first_name
  def first_name
    split_name.first
  end

  # @see Extractor::Base#last_name
  def last_name
    split_name.last
  end

  # @see Extractor::Base#username
  def username
    auth['info']['nickname']
  end

  # @see Extractor::Base#image_url
  def image_url
    auth['info']['image']
  end

  # @see Extractor::Base#uid
  def uid
    auth['uid']
  end

  # @see Extractor::Base#oauth_token
  def oauth_token
    auth['credentials']['token']
  end

  # @see Extractor::Base#oauth_secret
  def oauth_secret
    auth['credentials']['secret']
  end
end
