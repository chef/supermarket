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
  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :body]
  }
end
