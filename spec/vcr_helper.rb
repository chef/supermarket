require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data('<TOKEN>') do
    Supermarket::Config.github.fetch('access_token')
  end
  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :body]
  }
end
