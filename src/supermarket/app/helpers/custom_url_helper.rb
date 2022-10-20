module CustomUrlHelper
  #
  # This module defines URL helpers that are used throughout the application.
  # Each method here has a corresponding ENV variable in the .env template to
  # set appropriate default values.
  #

  def chef_domain
    ENV["CHEF_DOMAIN"] || "chef.io"
  end

  def progress_domain
    ENV["PROGRESS_DOMAIN"] || "progress.com"
  end

  def chef_server_url
    ENV["CHEF_SERVER_URL"] || "https://api.chef.io"
  end

  def chef_www_url(extra = nil)
    url = ENV["CHEF_WWW_URL"] || "https://www.#{chef_domain}"
    extra_dispatch(url, extra)
  end

  def progress_www_url(extra = nil)
    url = ENV["PROGRESS_WWW_URL"] || "https://www.#{progress_domain}"
    extra_dispatch(url, extra)
  end

  def chef_blog_url(extra = nil)
    url = ENV["CHEF_BLOG_URL"] || "https://chef.io/blog/"
    extra_dispatch(url, extra)
  end

  def chef_docs_url(extra = nil)
    url = ENV["CHEF_DOCS_URL"] || "https://docs.#{chef_domain}"
    extra_dispatch(url, extra)
  end

  def chef_downloads_url(extra = nil)
    url = ENV["CHEF_DOWNLOADS_URL"] || "https://www.#{chef_domain}/downloads"
    extra_dispatch(url, extra)
  end

  def chef_identity_url
    ENV["CHEF_IDENTITY_URL"] || "#{chef_server_url}/id"
  end

  def chef_manage_url
    ENV["CHEF_MANAGE_URL"] || chef_server_url
  end

  def chef_oauth2_url
    ENV["CHEF_OAUTH2_URL"] || chef_server_url
  end

  def chef_profile_url
    ENV["CHEF_PROFILE_URL"] || chef_manage_url
  end

  def chef_sign_up_url
    ENV["CHEF_SIGN_UP_URL"] || "#{chef_manage_url}/signup?ref=community"
  end

  def chef_training_url(extra = nil)
    url = ENV["CHEF_TRAINING_URL"] || "#{chef_www_url}/training"
    extra_dispatch(url, extra)
  end

  def learn_chef_url
    ENV["LEARN_CHEF_URL"] || "https://learn.#{chef_domain}"
  end

  def chef_status_url
    ENV["CHEF_STATUS_URL"] || "https://status.#{chef_domain}"
  end

  def community_slack_url
    ENV["CHEF_COMMUNITY_SLACK_URL"] || "https://community.#{chef_domain}/slack"
  end

  private

  def extra_dispatch(url, extra = nil)
    if extra.nil?
      url
    else
      "#{url}/#{extra}"
    end
  end
end
