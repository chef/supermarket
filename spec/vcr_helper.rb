require 'cgi'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data('<TOKEN>') do
    Supermarket::Config.github.fetch('access_token')
  end
  c.filter_sensitive_data('<PUBSUBHUBBUB_SECRET>') do
    CGI.escape(Supermarket::Config.pubsubhubbub.fetch('hub_secret'))
  end
  c.filter_sensitive_data('<PUBSUBHUBBUB_SECRET>') do
    Supermarket::Config.pubsubhubbub.fetch('hub_secret')
  end
  c.filter_sensitive_data('<PUBSUBHUBBUB_CALLBACK>') do
    CGI.escape(Supermarket::Config.pubsubhubbub.fetch('callback_url'))
  end
  c.filter_sensitive_data('<PUBSUBHUBBUB_CALLBACK>') do
    Supermarket::Config.pubsubhubbub.fetch('callback_url')
  end
  c.filter_sensitive_data('<CHEF_OAUTH2_APP_ID>') do
    ENV['CHEF_OAUTH2_APP_ID']
  end
  c.filter_sensitive_data('<CHEF_OAUTH2_SECRET>') do
    ENV['CHEF_OAUTH2_SECRET']
  end
  c.filter_sensitive_data('<VALID_OCID_OAUTH_TOKEN>') do
    ENV['VALID_OCID_OAUTH_TOKEN']
  end
  c.filter_sensitive_data('<VALID_OCID_REFRESH_TOKEN>') do
    ENV['VALID_OCID_REFRESH_TOKEN']
  end
  c.filter_sensitive_data('<OCID_REPLACEMENT_OAUTH_TOKEN>') do |interaction|
    if interaction.request.uri == 'https://id.opscode.com/id/oauth/token'
      body = nil

      begin
        body = JSON.parse(interaction.response.body)
      rescue JSON::ParserError
        body = {}
      end

      body['access_token']
    end
  end
  c.filter_sensitive_data('<OCID_REPLACEMENT_REFRESH_TOKEN>') do |interaction|
    if interaction.request.uri == 'https://id.opscode.com/id/oauth/token'
      body = nil

      begin
        body = JSON.parse(interaction.response.body)
      rescue JSON::ParserError
        body = {}
      end

      body['refresh_token']
    end
  end

  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :body]
  }
end
