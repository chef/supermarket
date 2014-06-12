require 'spec_helper'

describe Universe do
  let(:cookbook) { create(:cookbook) }
  let(:host) { Supermarket::Config.host }
  let(:routes) { Rails.application.routes.url_helpers }
  let(:version) { cookbook.cookbook_versions.first }

  it 'generates routes that are the same as Rails' do
    http_route = routes.api_v1_cookbook_version_download_url(
      cookbook,
      version,
      host: host,
      protocol: 'http'
    )
    https_route = routes.api_v1_cookbook_version_download_url(
      cookbook,
      version,
      host: host,
      protocol: 'https'
    )

    expect(Universe.download_path(cookbook.name, version.version, host, 'http')).to eql(http_route)
    expect(Universe.download_path(cookbook.name, version.version, host, 'https')).to eql(https_route)
  end
end
